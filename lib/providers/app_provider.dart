import 'dart:async';
import 'package:flutter/material.dart';

import '../models/reciter.dart';
import '../models/schedule_settings.dart';
import '../models/surah.dart';
import '../models/prayer_time_settings.dart';
import '../services/settings_service.dart';
import '../services/audio_handler.dart';
import 'audio_playback_provider.dart';
import 'schedule_provider.dart';
import 'surah_text_provider.dart';
import 'download_provider.dart';

/// Central coordinator using the Facade and Delegation patterns.
/// Delegates audio, scheduling, and surah text concerns to specialized providers
/// to maintain a clean single-responsibility codebase while preserving backward compatibility.
class AppProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  late final AudioPlaybackProvider _audioPlayback;
  late final ScheduleProvider _schedule;
  late final SurahTextProvider _surahText;
  DownloadProvider? _download;

  bool _isDarkMode = true;
  CityConfig _selectedCity = CityConfig.defaultCities.first;
  final Map<String, bool> _prayerNotifications = {};

  AppProvider() {
    _audioPlayback = AudioPlaybackProvider()..addListener(notifyListeners);
    _schedule = ScheduleProvider()..addListener(notifyListeners);
    _surahText = SurahTextProvider()..addListener(notifyListeners);
  }

  // General Config Getters
  bool get isDarkMode => _isDarkMode;
  CityConfig get selectedCity => _selectedCity;
  Map<String, bool> get prayerNotifications => _prayerNotifications;
  String get selectedAdhanId => _settingsService.selectedAdhanId;

  // Audio Playback Delegation Getters
  bool get isPlaying => _audioPlayback.isPlaying;
  bool get isLoading => _audioPlayback.isLoading;
  Duration get currentPosition => _audioPlayback.currentPosition;
  Duration get totalDuration => _audioPlayback.totalDuration;
  String? get errorMessage => _audioPlayback.errorMessage;
  Surah? get currentPlayingSurah => _audioPlayback.currentPlayingSurah;
  Reciter? get currentPlayingReciter => _audioPlayback.currentPlayingReciter;
  String get activeAudioTitle => _audioPlayback.activeAudioTitle;
  String get activeAudioSubtitle => _audioPlayback.activeAudioSubtitle;
  bool get isLiveStream => _audioPlayback.isLiveStream;
  bool get hasActiveAudio => _audioPlayback.hasActiveAudio;
  double get volume => _audioPlayback.volume;

  // Schedule Delegation Getters
  ScheduleSettings get settings => _schedule.settings;
  bool get isAzkarReminderEnabled => _schedule.isAzkarReminderEnabled;
  TimeOfDay get azkarMorningTime => _schedule.azkarMorningTime;
  TimeOfDay get azkarEveningTime => _schedule.azkarEveningTime;
  DateTime? get nextPlayback => _schedule.nextPlayback;
  int get playCount => _schedule.playCount;
  List<(DateTime, String)> get playHistory => _schedule.playHistory;
  Reciter get currentReciter => Reciter.findById(_schedule.settings.selectedReciterId);

  // Surah Text Delegation Getters
  bool get isLoadingSurahText => _surahText.isLoading;
  List<String>? getSurahText(int surahNumber) => _surahText.getSurahText(surahNumber);

  // Download Delegation Getters
  bool get isDownloading => _download?.isDownloadingAny ?? false;
  String get downloadingReciterName => _download?.downloadingReciterName ?? '';
  double get downloadProgress => _download?.downloadProgress ?? 0.0;

  /// Load shared configuration settings.
  Future<void> init(QuranAudioHandler audioHandler, DownloadProvider downloadProvider) async {
    if (_download != downloadProvider) {
      _download?.removeListener(notifyListeners);
      _download = downloadProvider;
      _download?.addListener(notifyListeners);
    }
    _audioPlayback.init(audioHandler);
    await _schedule.init();

    await _settingsService.init();
    _isDarkMode = _settingsService.isDarkMode;

    // Load Selected City
    final cityId = _settingsService.selectedCityId;
    _selectedCity = CityConfig.findById(cityId);

    // Load prayer alarm settings
    for (final prayerId in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      _prayerNotifications[prayerId] = _settingsService.getPrayerNotification(prayerId);
    }
  }

  /// Toggle visual theme dark/light mode.
  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    await _settingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Save and toggle notifications for a specific prayer time.
  Future<void> togglePrayerNotification(String prayerId) async {
    final currentVal = _prayerNotifications[prayerId] ?? true;
    _prayerNotifications[prayerId] = !currentVal;
    await _settingsService.setPrayerNotification(prayerId, !currentVal);
    notifyListeners();
  }

  /// Update app location/city settings.
  Future<void> updateSelectedCity(CityConfig city) async {
    _selectedCity = city;
    await _settingsService.setSelectedCityId(city.id);
    _schedule.reschedulePrayersForCity(city.id);
    notifyListeners();
  }

  // --- Audio Playback Delegation Methods ---
  Future<void> playSurah(Surah surah, Reciter reciter) => _audioPlayback.playSurah(surah, reciter);
  Future<void> playRadio(String url, String name) => _audioPlayback.playRadio(url, name);
  Future<void> stopRadio() => _audioPlayback.stopRadio();
  Future<void> togglePlayPause() => _audioPlayback.togglePlayPause();
  Future<void> seekTo(Duration position) => _audioPlayback.seekTo(position);
  Future<void> setVolume(double volume) => _audioPlayback.setVolume(volume);
  Future<void> stopPlayback() => _audioPlayback.stopPlayback();
  Future<void> stopQuranPlayback() => _audioPlayback.stopPlayback();

  // --- Play Al-Baqarah Now ---
  Future<void> playNow() async {
    final reciter = currentReciter;
    await _audioPlayback.playSurah(Surah.findByNumber(2), reciter);
    if (_audioPlayback.isPlaying) {
      await _schedule.logBaqarahPlayed(reciter.nameAr);
    }
  }

  // --- Schedule Delegation Methods ---
  Future<void> updateSettings(ScheduleSettings newSettings) => 
      _schedule.updateSettings(newSettings, selectedCityId: _selectedCity.id);
  Future<void> updateAzkarReminderSettings({
    required bool isEnabled,
    required TimeOfDay morningTime,
    required TimeOfDay eveningTime,
  }) => _schedule.updateAzkarSettings(
        isEnabled: isEnabled,
        morningTime: morningTime,
        eveningTime: eveningTime,
      );

  Future<void> selectReciter(String reciterId) async {
    final wasPlaying = isPlaying;
    final playingSurah = currentPlayingSurah;

    await _schedule.updateSettings(settings.copyWith(selectedReciterId: reciterId), selectedCityId: _selectedCity.id);

    // Switch reciter instantly if currently playing:
    if (wasPlaying) {
      final newReciter = Reciter.findById(reciterId);
      if (playingSurah != null) {
        await playSurah(playingSurah, newReciter);
      } else if (hasActiveAudio && activeAudioTitle.contains('البقرة')) {
        await playNow();
      }
    }
  }

  // --- Surah Text Delegation Methods ---
  Future<List<String>?> loadSurahText(int surahNumber) => _surahText.loadSurahText(surahNumber);

  // --- Download Delegation Methods ---
  Future<bool> isReciterCached(String reciterId) => _download?.isReciterCached(reciterId) ?? Future.value(false);
  Future<void> downloadReciter(Reciter reciter) => _download?.downloadReciter(reciter) ?? Future.value();
  void cancelDownload() => _download?.cancelDownloadBackwardCompat();

  @override
  void dispose() {
    _download?.removeListener(notifyListeners);
    _audioPlayback.dispose();
    _schedule.dispose();
    _surahText.dispose();
    super.dispose();
  }
}
