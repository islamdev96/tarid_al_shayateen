import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../models/reciter.dart';
import '../models/schedule_settings.dart';
import '../models/surah.dart';
import '../models/prayer_time_settings.dart';
import '../services/audio_handler.dart';
import '../services/scheduler_service.dart';
import '../services/settings_service.dart';

/// Central state management for the app.
class AppProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late QuranAudioHandler _audioHandler;

  ScheduleSettings _settings = const ScheduleSettings();
  bool _isPlaying = false;
  bool _isDarkMode = true;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _downloadingReciterName = '';
  bool _downloadCancelled = false;
  http.Client? _httpClient;
  double _volume = 1.0;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _alarmSub;
  StreamSubscription? _prayerAlarmSub;
  Timer? _foregroundTimer;

  // Azkar reminder variables
  bool _isAzkarReminderEnabled = true;
  TimeOfDay _azkarMorningTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _azkarEveningTime = const TimeOfDay(hour: 17, minute: 0);

  // Prayer times & Quran playback variables
  CityConfig _selectedCity = CityConfig.defaultCities.first;
  final Map<String, bool> _prayerNotifications = {};
  Surah? _currentPlayingSurah;
  Reciter? _currentPlayingReciter;
  StreamSubscription? _mediaItemSub;
  String? _customTitle;
  String? _customSubtitle;

  // Quran Text variables
  bool _isLoadingSurahText = false;
  final Map<int, List<String>> _cachedSurahTexts = {};

  // Getters
  bool get isLoadingSurahText => _isLoadingSurahText;
  ScheduleSettings get settings => _settings;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;
  String get downloadingReciterName => _downloadingReciterName;
  double get volume => _volume;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get errorMessage => _errorMessage;
  Reciter get currentReciter => Reciter.findById(_settings.selectedReciterId);
  DateTime? get nextPlayback => _settings.getNextPlaybackTime();
  int get playCount => _settingsService.playCount;
  List<(DateTime, String)> get playHistory => _settingsService.playHistory;
  bool get isDarkMode => _isDarkMode;
  bool get isAzkarReminderEnabled => _isAzkarReminderEnabled;
  TimeOfDay get azkarMorningTime => _azkarMorningTime;
  TimeOfDay get azkarEveningTime => _azkarEveningTime;

  CityConfig get selectedCity => _selectedCity;
  Map<String, bool> get prayerNotifications => _prayerNotifications;
  Surah? get currentPlayingSurah => _currentPlayingSurah;
  Reciter? get currentPlayingReciter => _currentPlayingReciter;
  String get activeAudioTitle => _customTitle ?? (_currentPlayingSurah != null ? 'سورة ${_currentPlayingSurah!.nameAr}' : '');
  String get activeAudioSubtitle => _customSubtitle ?? (_currentPlayingReciter != null ? 'القارئ: ${_currentPlayingReciter!.nameAr}' : '');
  bool get isLiveStream => _customTitle != null;
  bool get hasActiveAudio => _currentPlayingSurah != null || _customTitle != null;

  /// Initialize all services.
  Future<void> init(QuranAudioHandler audioHandler) async {
    _audioHandler = audioHandler;
    await _settingsService.init();
    _settings = await _settingsService.loadSettings();
    _isDarkMode = _settingsService.isDarkMode;

    // Load Azkar reminder settings
    _isAzkarReminderEnabled = _settingsService.isAzkarReminderEnabled;
    _azkarMorningTime = TimeOfDay(
      hour: _settingsService.azkarMorningHour,
      minute: _settingsService.azkarMorningMinute,
    );
    _azkarEveningTime = TimeOfDay(
      hour: _settingsService.azkarEveningHour,
      minute: _settingsService.azkarEveningMinute,
    );

    // Load Selected City and Prayer notifications
    final cityId = _settingsService.selectedCityId;
    _selectedCity = CityConfig.findById(cityId);
    for (final prayerId in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      _prayerNotifications[prayerId] = _settingsService.getPrayerNotification(prayerId);
    }

    // Listen to current media item to show in mini player
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
            orElse: () => currentReciter,
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

    // Listen to processing state (for completion detection)
    _stateSub = _audioHandler.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onPlaybackCompleted();
      } else if (state == ProcessingState.ready) {
        _totalDuration = _audioHandler.duration ?? _totalDuration;
        _isLoading = false;
        notifyListeners();
      }
    });

    // Register alarm port and listen
    final port = SchedulerService.registerPort();
    _alarmSub = port.listen((message) {
      if (message == 'play') {
        playNow();
      }
    });

    // Register prayer alarm port and listen for foreground Adhan playback
    final prayerPort = SchedulerService.registerPrayerPort();
    _prayerAlarmSub = prayerPort.listen((message) {
      if (message.toString().startsWith('play_adhan_')) {
        final prayerId = message.toString().split('_').last;
        _playAdhanForeground(prayerId);
      }
    });

    // Schedule next Baqarah playback if enabled
    if (_settings.isEnabled) {
      _scheduleNext();
    }

    // Schedule next prayer alarm
    _schedulePrayerAlarms();

    // Schedule Azkar reminders if enabled
    if (_isAzkarReminderEnabled) {
      _scheduleAzkarReminders();
    }

    notifyListeners();

    // Check if an alarm was missed while app was closed
    final hasPending = await SchedulerService.checkPendingAlarm();
    if (hasPending && _settings.isEnabled) {
      playNow();
    }

    // Auto-download offline reciter (visible to user)
    _autoDownloadOffline();
  }

  /// Download the offline reciter's audio if not cached yet.
  /// Progress is shown on the home screen.
  Future<void> _autoDownloadOffline() async {
    final offlineReciter = Reciter.defaultReciters.first; // Al-Hussary
    final path = await _getCachedFilePath(offlineReciter.id);
    if (!await File(path).exists()) {
      try {
        await _downloadAndCache(offlineReciter);
      } catch (e) {
        _errorMessage = 'فشل تحميل القارئ الافتراضي - تحقق من الإنترنت';
        _isDownloading = false;
        notifyListeners();
      }
    }
  }

  /// Play Surah Al-Baqarah now with the selected reciter.
  Future<void> playNow() async {
    if (_isLoading || _isPlaying) return; // Prevent double-tap or restarting if already playing
    _isLoading = true;
    _errorMessage = null;
    _customTitle = null;
    _customSubtitle = null;
    notifyListeners();

    final reciter = currentReciter;

    try {
      // Always try cached file first (any reciter)
      final cachedPath = await _getCachedFilePath(reciter.id);
      if (await File(cachedPath).exists()) {
        await _audioHandler.playFromFile(cachedPath, reciter.nameAr);
      } else if (reciter.isOffline) {
        // Download offline reciter, then play
        await _downloadAndCache(reciter);
        await _audioHandler.playFromFile(cachedPath, reciter.nameAr);
      } else {
        // Online playback
        try {
          await _audioHandler.playFromUrl(reciter.surahBaqarahUrl, reciter.nameAr);
        } catch (_) {
          // Fallback to any cached reciter
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

      // Record last played
      _settings = _settings.copyWith(lastPlayedAt: DateTime.now());
      await _settingsService.saveSettings(_settings);
      await _settingsService.updateLastPlayed(DateTime.now());

      // Log play stats
      await _settingsService.incrementPlayCount();
      await _settingsService.addPlayHistory(reciter.nameAr);
    } catch (e) {
      _errorMessage = 'حدث خطأ: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pause/resume playback.
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  /// Stop playback.
  Future<void> stopPlayback() async {
    await _audioHandler.stop();
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  /// Seek to position.
  Future<void> seekTo(Duration position) async {
    await _audioHandler.seek(position);
  }

  /// Set playback volume (0.0 to 1.0).
  Future<void> setVolume(double vol) async {
    _volume = vol;
    await _audioHandler.setVolume(vol);
    notifyListeners();
  }

  /// Update schedule settings and reschedule.
  Future<void> updateSettings(ScheduleSettings newSettings) async {
    bool timeChanged = _settings.playbackTime != newSettings.playbackTime || 
                       _settings.repeatMode != newSettings.repeatMode || 
                       _settings.intervalDays != newSettings.intervalDays;
    
    if (timeChanged) {
      // If the user changed the time, reset lastPlayedAt so it can trigger today for testing
      newSettings = newSettings.copyWith(
        lastPlayedAt: null, // this doesn't clear it in copyWith, we must create a new object
      );
      // Wait, copyWith doesn't support nulling out values. We create a new ScheduleSettings
      newSettings = ScheduleSettings(
        playbackTime: newSettings.playbackTime,
        repeatMode: newSettings.repeatMode,
        intervalDays: newSettings.intervalDays,
        selectedWeekDays: newSettings.selectedWeekDays,
        isEnabled: newSettings.isEnabled,
        selectedReciterId: newSettings.selectedReciterId,
        lastPlayedAt: null, // Reset history to allow triggering today
      );
    }

    _settings = newSettings;
    await _settingsService.saveSettings(_settings);

    if (_settings.isEnabled) {
      _scheduleNext();
    } else {
      await SchedulerService.cancelAll();
    }

    notifyListeners();
  }

  /// Select a different reciter.
  Future<void> selectReciter(String reciterId) async {
    _settings = _settings.copyWith(selectedReciterId: reciterId);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  /// Download the offline reciter's audio and cache it with progress.
  Future<void> _downloadAndCache(Reciter reciter) async {
    final path = await _getCachedFilePath(reciter.id);
    final file = File(path);

    if (!await file.exists()) {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadingReciterName = reciter.nameAr;
      _downloadCancelled = false;
      notifyListeners();

      _httpClient = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(reciter.surahBaqarahUrl));
        final response = await _httpClient!.send(request);

        if (response.statusCode == 200) {
          final totalBytes = response.contentLength ?? 0;
          int receivedBytes = 0;
          final builder = BytesBuilder();
          double lastReportedProgress = 0.0;

          await for (final chunk in response.stream) {
            if (_downloadCancelled) {
              throw Exception('تم إلغاء التحميل');
            }
            builder.add(chunk);
            receivedBytes += chunk.length;
            if (totalBytes > 0) {
              final progress = receivedBytes / totalBytes;
              // Notify only every 1% increase to prevent UI thread flooding (Skipped 6651 frames issue)
              if (progress - lastReportedProgress >= 0.01 || progress == 1.0) {
                _downloadProgress = progress;
                lastReportedProgress = progress;
                notifyListeners();
              }
            }
          }

          if (!_downloadCancelled) {
            await file.writeAsBytes(builder.takeBytes());
          }
        } else {
          throw Exception('فشل تحميل الملف الصوتي');
        }
      } catch (e) {
        if (_downloadCancelled) {
          throw Exception('تم إلغاء التحميل');
        }
        rethrow;
      } finally {
        _httpClient?.close();
        _httpClient = null;
        _isDownloading = false;
        _downloadProgress = _downloadCancelled ? 0.0 : 1.0;
        _downloadingReciterName = '';
        notifyListeners();
      }
    }
  }

  /// Cancel ongoing download.
  void cancelDownload() {
    _downloadCancelled = true;
    _httpClient?.close();
    _httpClient = null;
    _isDownloading = false;
    _downloadProgress = 0.0;
    _downloadingReciterName = '';
    notifyListeners();
  }

  /// Check if a specific reciter is cached offline.
  Future<bool> isReciterCached(String reciterId) async {
    final path = await _getCachedFilePath(reciterId);
    return File(path).exists();
  }

  /// Download a reciter for offline use.
  Future<void> downloadReciter(Reciter reciter) async {
    await _downloadAndCache(reciter);
  }

  /// Find any cached reciter file as fallback.
  Future<String?> _findAnyCachedReciter() async {
    for (final r in Reciter.defaultReciters) {
      final path = await _getCachedFilePath(r.id);
      if (await File(path).exists()) return path;
    }
    return null;
  }

  Future<String> _getCachedFilePath(String reciterId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_baqarah_$reciterId.mp3';
  }

  void _onPlaybackCompleted() {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _currentPlayingSurah = null;

    // Schedule the next playback
    if (_settings.isEnabled) {
      _scheduleNext();
    }

    notifyListeners();
  }

  void _scheduleNext() {
    final nextTime = _settings.getNextPlaybackTime();
    if (nextTime != null) {
      SchedulerService.scheduleNext(nextTime);
      
      // Also schedule a Dart Timer as a reliable fallback if the app remains open in the foreground
      _foregroundTimer?.cancel();
      final duration = nextTime.difference(DateTime.now());
      if (duration.inSeconds > 0) {
        _foregroundTimer = Timer(duration, () {
          debugPrint('Foreground Timer triggered playback!');
          playNow();
        });
      }
    }
  }

  /// Toggle between light and dark themes.
  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    await _settingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Update Azkar reminder settings and reschedule.
  Future<void> updateAzkarReminderSettings({
    required bool isEnabled,
    required TimeOfDay morningTime,
    required TimeOfDay eveningTime,
  }) async {
    _isAzkarReminderEnabled = isEnabled;
    _azkarMorningTime = morningTime;
    _azkarEveningTime = eveningTime;

    await _settingsService.setAzkarReminderEnabled(isEnabled);
    await _settingsService.setAzkarMorningHour(morningTime.hour);
    await _settingsService.setAzkarMorningMinute(morningTime.minute);
    await _settingsService.setAzkarEveningHour(eveningTime.hour);
    await _settingsService.setAzkarEveningMinute(eveningTime.minute);

    _scheduleAzkarReminders();

    notifyListeners();
  }

  /// Internal helper to reschedule Azkar alarms.
  void _scheduleAzkarReminders() {
    SchedulerService.scheduleAzkarReminders(
      _isAzkarReminderEnabled,
      _azkarMorningTime,
      _azkarEveningTime,
    );
  }

  // --- Prayer Times Settings methods ---
  Future<void> updateSelectedCity(String cityId) async {
    _selectedCity = CityConfig.findById(cityId);
    await _settingsService.setSelectedCityId(cityId);
    _schedulePrayerAlarms();
    notifyListeners();
  }

  Future<void> togglePrayerNotification(String prayerId) async {
    final currentVal = _prayerNotifications[prayerId] ?? true;
    _prayerNotifications[prayerId] = !currentVal;
    await _settingsService.setPrayerNotification(prayerId, !currentVal);
    _schedulePrayerAlarms();
    notifyListeners();
  }

  // --- Dynamic Quran Playback methods ---
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
      debugPrint('Error playing Surah: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stopQuranPlayback() async {
    await stopPlayback();
    _currentPlayingSurah = null;
    notifyListeners();
  }

  /// Play a live Quran Radio stream.
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
      // Stop any currently playing audio
      await stopPlayback();

      await _audioHandler.playFromUrl(url, 'إذاعة بث مباشر', surahName: name, isLiveStream: true);
      _isPlaying = true;
    } catch (e) {
      _errorMessage = 'فشل تشغيل الإذاعة المباشرة: تحقق من الإنترنت';
      _customTitle = null;
      _customSubtitle = null;
      debugPrint('Error playing Radio: $e');
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

  void _schedulePrayerAlarms() {
    SchedulerService.scheduleNextPrayer(_selectedCity);
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
      debugPrint('Error playing Adhan in foreground: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  List<String>? getSurahText(int number) => _cachedSurahTexts[number];

  Future<List<String>?> loadSurahText(int surahNumber) async {
    if (_cachedSurahTexts.containsKey(surahNumber)) {
      return _cachedSurahTexts[surahNumber];
    }

    final path = await _getSurahTextFilePath(surahNumber);
    final file = File(path);

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final verses = content.split('\n');
        _cachedSurahTexts[surahNumber] = verses;
        return verses;
      } catch (e) {
        debugPrint('Error reading cached Surah text: $e');
      }
    }

    _isLoadingSurahText = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahsJson = data['data']['ayahs'] as List;
        final verses = ayahsJson.map((a) => a['text'] as String).toList();

        // Strip Bismillah from the first verse if it's there
        if (verses.isNotEmpty && surahNumber != 1 && surahNumber != 9) {
          const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
          if (verses[0].startsWith(bismillah)) {
            verses[0] = verses[0].substring(bismillah.length).trim();
          }
        }

        // Save to local cache file
        await file.writeAsString(verses.join('\n'));
        _cachedSurahTexts[surahNumber] = verses;
        return verses;
      } else {
        throw Exception('فشل الاتصال بالخادم. رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل نص السورة: تأكد من اتصالك بالإنترنت';
      debugPrint('Error loading Surah text: $e');
      return null;
    } finally {
      _isLoadingSurahText = false;
      notifyListeners();
    }
  }

  Future<String> _getSurahTextFilePath(int surahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/surah_text_$surahNumber.txt';
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
