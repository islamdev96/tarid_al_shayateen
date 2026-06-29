import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/reciter.dart';
import '../models/surah.dart';
import '../models/schedule_settings.dart';
import '../services/audio_handler.dart';
import '../services/scheduler_service.dart';
import '../services/settings_service.dart';

class AudioProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late QuranAudioHandler _audioHandler;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isInitializing = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;
  double _volume = 1.0;

  Surah? _currentPlayingSurah;
  Reciter? _currentPlayingReciter;
  String? _customTitle;
  String? _customSubtitle;

  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _mediaItemSub;
  StreamSubscription? _alarmSub;
  StreamSubscription? _prayerAlarmSub;
  Timer? _foregroundTimer;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  double get volume => _volume;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get errorMessage => _errorMessage;

  Surah? get currentPlayingSurah => _currentPlayingSurah;
  Reciter? get currentPlayingReciter => _currentPlayingReciter;
  String get activeAudioTitle => _customTitle ?? (_currentPlayingSurah != null ? 'سورة ${_currentPlayingSurah!.nameAr}' : '');
  String get activeAudioSubtitle => _customSubtitle ?? (_currentPlayingReciter != null ? 'القارئ: ${_currentPlayingReciter!.nameAr}' : '');
  bool get isLiveStream => _customTitle != null;
  bool get hasActiveAudio => _currentPlayingSurah != null || _customTitle != null;

  Future<void> init(QuranAudioHandler audioHandler) async {
    _audioHandler = audioHandler;
    await _settingsService.init();

    _mediaItemSub = _audioHandler.mediaItem.listen((item) {
      if (item != null) {
        if (item.artist == 'إذاعة بث مباشر') {
          _customTitle = item.title;
          _customSubtitle = 'بث مباشر';
          _currentPlayingSurah = null;
          _currentPlayingReciter = null;
        } else {
          _customTitle = null;
          _customSubtitle = null;
          _currentPlayingSurah = Surah.allSurahs.firstWhere(
            (s) => s.nameAr == item.title,
            orElse: () => Surah.findByNumber(2),
          );
          _currentPlayingReciter = Reciter.defaultReciters.firstWhere(
            (r) => r.nameAr == item.artist,
            orElse: () => Reciter.defaultReciters.first,
          );
        }
        _isPlaying = _audioHandler.isPlaying;
        if (!_isInitializing) notifyListeners();
      } else {
        _currentPlayingSurah = null;
        _currentPlayingReciter = null;
        _customTitle = null;
        _customSubtitle = null;
        if (!_isInitializing) notifyListeners();
      }
    });

    _positionSub = _audioHandler.positionStream.listen((pos) {
      _currentPosition = pos;
      if (!_isInitializing) notifyListeners();
    });

    _stateSub = _audioHandler.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        _onPlaybackCompleted();
      } else if (state == ProcessingState.ready) {
        _totalDuration = _audioHandler.duration ?? _totalDuration;
        _isLoading = false;
        if (!_isInitializing) notifyListeners();
      }
    });

    final port = SchedulerService.registerPort();
    _alarmSub = port?.listen((message) {
      if (message == 'play') {
        playNow();
      }
    });

    final prayerPort = SchedulerService.registerPrayerPort();
    _prayerAlarmSub = prayerPort?.listen((message) {
      if (message.toString().startsWith('play_adhan_')) {
        final prayerId = message.toString().split('_').last;
        _playAdhanForeground(prayerId);
      }
    });

    final settings = await _settingsService.loadSettings();
    if (settings.isEnabled) {
      _scheduleNext(settings);
    }

    _isInitializing = false;
    notifyListeners();

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> playNow() async {
    if (_isLoading || _isPlaying) return;
    _isLoading = true;
    _errorMessage = null;
    _customTitle = null;
    _customSubtitle = null;
    notifyListeners();

    final settings = await _settingsService.loadSettings();
    final reciter = Reciter.findById(settings.selectedReciterId);

    try {
      final cachedPath = await _getCachedFilePath(reciter.id);
      if (await File(cachedPath).exists()) {
        await _audioHandler.playFromFile(cachedPath, reciter.nameAr);
      } else if (reciter.isOffline) {
        // Will throw if download is required since AudioProvider doesn't download directly.
        // It's expected DownloadProvider does this beforehand.
        _errorMessage = 'الملف غير محمل. يرجى تحميل القارئ أولاً.';
        return;
      } else {
        try {
          await _audioHandler.playFromUrl(reciter.surahBaqarahUrl, reciter.nameAr);
        } catch (_) {
          final fallbackPath = await _findAnyCachedReciter();
          if (fallbackPath != null) {
            await _audioHandler.playFromFile(fallbackPath, 'قارئ محفوظ');
          } else {
            _errorMessage = 'لا يوجد اتصال بالإنترنت ولا نسخة محلية متوفرة';
            return;
          }
        }
      }

      _isPlaying = true;
      _totalDuration = _audioHandler.duration ?? const Duration(hours: 2);

      final newSettings = settings.copyWith(lastPlayedAt: DateTime.now());
      await _settingsService.saveSettings(newSettings);
      await _settingsService.updateLastPlayed(DateTime.now());
      await _settingsService.incrementPlayCount();
      await _settingsService.addPlayHistory(reciter.nameAr);
    } catch (e) {
      _errorMessage = 'حدث خطأ: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playSurah(Surah surah, Reciter reciter) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _customTitle = null;
    _customSubtitle = null;
    notifyListeners();

    try {
      final surahUrl = '${reciter.serverUrl}${surah.formattedNumber}.mp3';
      final isBaqarah = surah.number == 2;
      final cachedPath = await _getCachedFilePath(reciter.id);
      
      if (isBaqarah && await File(cachedPath).exists()) {
        await _audioHandler.playFromFile(cachedPath, reciter.nameAr, surahName: surah.nameAr);
      } else {
        await _audioHandler.playFromUrl(surahUrl, reciter.nameAr, surahName: surah.nameAr);
      }

      _currentPlayingSurah = surah;
      _currentPlayingReciter = reciter;
      _isPlaying = true;
      _totalDuration = _audioHandler.duration ?? const Duration(hours: 2);
    } catch (e) {
      _errorMessage = 'فشل تشغيل الصوت: تحقق من اتصال الإنترنت';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playRadio(String url, String name) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _customTitle = name;
    _customSubtitle = 'بث مباشر';
    _currentPlayingSurah = null;
    _currentPlayingReciter = null;
    notifyListeners();

    try {
      await stopPlayback();
      await _audioHandler.playFromUrl(url, 'إذاعة بث مباشر', surahName: name, isLiveStream: true);
      _isPlaying = true;
    } catch (e) {
      _errorMessage = 'فشل تشغيل الإذاعة المباشرة: تحقق من الإنترنت';
      _customTitle = null;
      _customSubtitle = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _audioHandler.stop();
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _currentPlayingSurah = null;
    _customTitle = null;
    _customSubtitle = null;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
  }

  Future<void> setVolume(double vol) async {
    _volume = vol;
    await _audioHandler.setVolume(vol);
    notifyListeners();
  }

  Future<void> _playAdhanForeground(String prayerId) async {
    final prayerName = _getPrayerNameAr(prayerId);
    try {
      await stopPlayback();
      _isLoading = true;
      _customTitle = 'أذان صلاة $prayerName';
      _customSubtitle = 'المسجد النبوي';
      notifyListeners();

      const adhanUrl = 'https://www.islamcan.com/audio/adhan/azan1.mp3';
      await _audioHandler.playFromUrl(adhanUrl, 'المسجد النبوي', surahName: 'أذان صلاة $prayerName');
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing Adhan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onPlaybackCompleted() async {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _currentPlayingSurah = null;
    
    final settings = await _settingsService.loadSettings();
    if (settings.isEnabled) {
      _scheduleNext(settings);
    }
    notifyListeners();
  }

  void _scheduleNext(ScheduleSettings settings) {
    final nextTime = settings.getNextPlaybackTime();
    if (nextTime != null) {
      SchedulerService.scheduleNext(nextTime);
      _foregroundTimer?.cancel();
      final duration = nextTime.difference(DateTime.now());
      if (duration.inSeconds > 0) {
        _foregroundTimer = Timer(duration, () {
          playNow();
        });
      }
    }
  }

  Future<String?> _findAnyCachedReciter() async {
    if (kIsWeb) return null;
    for (final r in Reciter.defaultReciters) {
      final path = await _getCachedFilePath(r.id);
      if (await File(path).exists()) return path;
    }
    return null;
  }

  Future<String> _getCachedFilePath(String reciterId) async {
    if (kIsWeb) return '';
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_baqarah_$reciterId.mp3';
  }

  String _getPrayerNameAr(String id) {
    switch (id) {
      case 'fajr': return 'الفجر';
      case 'dhuhr': return 'الظهر';
      case 'asr': return 'العصر';
      case 'maghrib': return 'المغرب';
      case 'isha': return 'العشاء';
      default: return '';
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _alarmSub?.cancel();
    _prayerAlarmSub?.cancel();
    _mediaItemSub?.cancel();
    _foregroundTimer?.cancel();
    super.dispose();
  }
}
