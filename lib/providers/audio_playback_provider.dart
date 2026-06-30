import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/reciter.dart';
import '../models/surah.dart';
import '../models/adhan_sound.dart';
import '../services/audio_handler.dart';
import '../services/settings_service.dart';

/// Provider responsible specifically for handling audio playback (Quran, Live Radio, Adhan).
class AudioPlaybackProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late QuranAudioHandler _audioHandler;

  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;

  Surah? _currentPlayingSurah;
  Reciter? _currentPlayingReciter;
  String? _customTitle;
  String? _customSubtitle;

  StreamSubscription? _mediaItemSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _accelerometerSub;

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

  /// Initialize audio stream listeners.
  void init(QuranAudioHandler audioHandler) {
    _audioHandler = audioHandler;

    // Listen to current media item to show in player UI
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
            orElse: () => Surah.findByNumber(2), // default to Baqarah
          );
          _currentPlayingReciter = Reciter.defaultReciters.firstWhere(
            (r) => r.nameAr == item.artist,
            orElse: () => Reciter.defaultReciters.first,
          );
        }
        _isPlaying = _audioHandler.isPlaying;
        notifyListeners();
      } else {
        _currentPlayingSurah = null;
        _currentPlayingReciter = null;
        _customTitle = null;
        _customSubtitle = null;
        notifyListeners();
      }
    });

    // Listen to audio position updates
    _positionSub = _audioHandler.positionStream.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    // Listen to processing state
    _stateSub = _audioHandler.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onPlaybackCompleted();
      } else if (state == ProcessingState.ready) {
        _totalDuration = _audioHandler.duration ?? _totalDuration;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Play a Surah by a specific reciter.
  Future<void> playSurah(Surah surah, Reciter reciter) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _customTitle = null;
    _customSubtitle = null;
    notifyListeners();

    try {
      final surahUrl = '${reciter.serverUrl}${surah.formattedNumber}.mp3';

      if (kIsWeb) {
        await _audioHandler.playFromUrl(surahUrl, reciter.nameAr, surahName: surah.nameAr);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final cachedPath = surah.number == 2 
            ? '${dir.path}/surah_baqarah_${reciter.id}.mp3'
            : '${dir.path}/surah_${surah.number}_${reciter.id}.mp3';
        
        if (await File(cachedPath).exists()) {
          await _audioHandler.playFromFile(cachedPath, reciter.nameAr, surahName: surah.nameAr);
        } else {
          await _audioHandler.playFromUrl(surahUrl, reciter.nameAr, surahName: surah.nameAr);
        }
      }

      _currentPlayingSurah = surah;
      _currentPlayingReciter = reciter;
      _isPlaying = true;
      _totalDuration = _audioHandler.duration ?? const Duration(hours: 2);
    } catch (e) {
      _errorMessage = 'فشل تشغيل الصوت: تحقق من اتصال الإنترنت';
      debugPrint('Error playing Surah: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Play a live Radio stream.
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
      _errorMessage = 'فشل تشغيل الإذاعة: تحقق من اتصال الإنترنت';
      debugPrint('Error playing radio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stop live radio stream.
  Future<void> stopRadio() async {
    await stopPlayback();
    _customTitle = null;
    _customSubtitle = null;
    notifyListeners();
  }

  /// Play Adhan sound (foreground).
  Future<void> playAdhanForeground(String prayerId, String prayerName) async {
    try {
      await stopPlayback();
      _isLoading = true;
      _customTitle = 'أذان صلاة $prayerName';
      final adhanId = _settingsService.getPrayerAdhanId(prayerId);
      final adhan = AdhanSound.findById(adhanId);
      _customSubtitle = adhan.nameAr;
      notifyListeners();

      if (kIsWeb) {
        await _audioHandler.playFromUrl(adhan.url, adhan.nameAr, surahName: 'أذان صلاة $prayerName');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/adhan_$adhanId.mp3';

        if (await File(path).exists()) {
          await _audioHandler.playFromFile(path, adhan.nameAr, surahName: 'أذان صلاة $prayerName');
        } else {
          await _audioHandler.playFromUrl(adhan.url, adhan.nameAr, surahName: 'أذان صلاة $prayerName');
        }
      }
      _isPlaying = true;
      _startAccelerometerListener();
    } catch (e) {
      debugPrint('Error playing Adhan in foreground: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pause/Resume playback.
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioHandler.pause();
      _isPlaying = false;
    } else {
      await _audioHandler.play();
      _isPlaying = true;
    }
    notifyListeners();
  }

  /// Seek to position.
  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  /// Adjust volume.
  Future<void> setVolume(double volume) async {
    await _audioHandler.setVolume(volume);
    _volume = volume;
    notifyListeners();
  }

  /// Stop all playback.
  Future<void> stopPlayback() async {
    await _audioHandler.stop();
    _isPlaying = false;
    _currentPlayingSurah = null;
    _currentPlayingReciter = null;
    _customTitle = null;
    _customSubtitle = null;
    _currentPosition = Duration.zero;
    _stopAccelerometerListener();
    notifyListeners();
  }

  void _onPlaybackCompleted() {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _stopAccelerometerListener();
    notifyListeners();
  }

  void _startAccelerometerListener() {
    _accelerometerSub?.cancel();
    if (kIsWeb) return;
    
    final flipToMuteEnabled = _settingsService.isFlipToMuteEnabled;
    if (!flipToMuteEnabled) return;

    _accelerometerSub = accelerometerEventStream().listen((event) {
      if (event.z < -8.0) {
        debugPrint('Device flipped face down! Muting Adhan.');
        stopPlayback();
      }
    });
  }

  void _stopAccelerometerListener() {
    _accelerometerSub?.cancel();
    _accelerometerSub = null;
  }

  @override
  void dispose() {
    _mediaItemSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _stopAccelerometerListener();
    super.dispose();
  }
}
