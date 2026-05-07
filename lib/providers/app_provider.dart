import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../models/reciter.dart';
import '../models/schedule_settings.dart';
import '../services/audio_handler.dart';
import '../services/scheduler_service.dart';
import '../services/settings_service.dart';

/// Central state management for the app.
class AppProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late QuranAudioHandler _audioHandler;

  ScheduleSettings _settings = const ScheduleSettings();
  bool _isPlaying = false;
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

  // Getters
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

  /// Initialize all services.
  Future<void> init(QuranAudioHandler audioHandler) async {
    _audioHandler = audioHandler;
    await _settingsService.init();
    _settings = await _settingsService.loadSettings();

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

    // Schedule next if enabled
    if (_settings.isEnabled) {
      _scheduleNext();
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
    if (_isLoading) return; // Prevent double-tap
    _isLoading = true;
    _errorMessage = null;
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
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _alarmSub?.cancel();
    super.dispose();
  }
}
