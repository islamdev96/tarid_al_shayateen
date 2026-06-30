import 'dart:async';
import 'package:flutter/material.dart';

import '../models/schedule_settings.dart';
import '../models/prayer_time_settings.dart';
import '../services/settings_service.dart';
import '../services/scheduler_service.dart';

/// Provider responsible for handling and scheduling all timers, daily reminders (Azkar), and prayer time alarms.
class ScheduleProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  ScheduleSettings _settings = const ScheduleSettings();
  bool _isAzkarReminderEnabled = true;
  TimeOfDay _azkarMorningTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _azkarEveningTime = const TimeOfDay(hour: 17, minute: 0);

  // Getters
  ScheduleSettings get settings => _settings;
  bool get isAzkarReminderEnabled => _isAzkarReminderEnabled;
  TimeOfDay get azkarMorningTime => _azkarMorningTime;
  TimeOfDay get azkarEveningTime => _azkarEveningTime;
  DateTime? get nextPlayback => _settings.getNextPlaybackTime();
  int get playCount => _settingsService.playCount;
  List<(DateTime, String)> get playHistory => _settingsService.playHistory;

  /// Initialize scheduler and load settings.
  Future<void> init() async {
    await _settingsService.init();
    _settings = await _settingsService.loadSettings();

    // Load Azkar settings
    _isAzkarReminderEnabled = _settingsService.isAzkarReminderEnabled;
    _azkarMorningTime = TimeOfDay(
      hour: _settingsService.azkarMorningHour,
      minute: _settingsService.azkarMorningMinute,
    );
    _azkarEveningTime = TimeOfDay(
      hour: _settingsService.azkarEveningHour,
      minute: _settingsService.azkarEveningMinute,
    );

    // Initial schedules
    if (_settings.isEnabled) {
      _scheduleNextBaqarah();
    }
    _schedulePrayerAlarms();
    if (_isAzkarReminderEnabled) {
      _scheduleAzkarReminders();
    }
  }

  /// Update Baqarah schedule settings.
  Future<void> updateSettings(ScheduleSettings newSettings, {required String selectedCityId}) async {
    bool timeChanged = _settings.playbackTime != newSettings.playbackTime || 
                       _settings.repeatMode != newSettings.repeatMode || 
                       _settings.intervalDays != newSettings.intervalDays;
    
    if (timeChanged) {
      newSettings = ScheduleSettings(
        playbackTime: newSettings.playbackTime,
        repeatMode: newSettings.repeatMode,
        intervalDays: newSettings.intervalDays,
        selectedWeekDays: newSettings.selectedWeekDays,
        isEnabled: newSettings.isEnabled,
        selectedReciterId: newSettings.selectedReciterId,
        lastPlayedAt: null, 
      );
    }

    _settings = newSettings;
    await _settingsService.saveSettings(_settings);

    if (!_settings.isEnabled) {
      await SchedulerService.cancelAll();
    } else {
      _scheduleNextBaqarah();
    }
    
    _schedulePrayerAlarms(selectedCityId: selectedCityId);
    notifyListeners();
  }

  /// Update Azkar reminder settings.
  Future<void> updateAzkarSettings({
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

  /// Triggered after a Baqarah playback is successfully initiated to record logs.
  Future<void> logBaqarahPlayed(String reciterName) async {
    _settings = _settings.copyWith(lastPlayedAt: DateTime.now());
    await _settingsService.saveSettings(_settings);
    await _settingsService.updateLastPlayed(DateTime.now());
    await _settingsService.incrementPlayCount();
    await _settingsService.addPlayHistory(reciterName);
    
    if (_settings.isEnabled) {
      _scheduleNextBaqarah();
    }
    notifyListeners();
  }

  void _scheduleNextBaqarah() {
    final nextTime = _settings.getNextPlaybackTime();
    if (nextTime != null) {
      SchedulerService.scheduleNext(nextTime);
    }
  }

  void _schedulePrayerAlarms({String? selectedCityId}) {
    CityConfig city;
    if (_settingsService.locationMode == 'automatic') {
      city = CityConfig(
        id: 'gps',
        nameAr: 'الموقع الحالي',
        nameEn: 'Current Location',
        latitude: _settingsService.gpsLatitude,
        longitude: _settingsService.gpsLongitude,
      );
    } else {
      final cityId = selectedCityId ?? _settingsService.selectedCityId;
      city = CityConfig.findById(cityId);
    }
    SchedulerService.scheduleNextPrayer(city);
  }

  void _scheduleAzkarReminders() {
    SchedulerService.scheduleAzkarReminders(
      _isAzkarReminderEnabled,
      _azkarMorningTime,
      _azkarEveningTime,
    );
  }

  /// Trigger reschedule on city change.
  void reschedulePrayersForCity(String cityId) {
    _schedulePrayerAlarms(selectedCityId: cityId);
  }
}
