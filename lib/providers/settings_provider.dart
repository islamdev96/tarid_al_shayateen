import 'package:flutter/material.dart';
import '../models/schedule_settings.dart';
import '../services/settings_service.dart';
import '../services/scheduler_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  ScheduleSettings _settings = const ScheduleSettings();
  bool _isDarkMode = true;
  bool _isInitializing = true;

  // Azkar reminder variables
  bool _isAzkarReminderEnabled = true;
  TimeOfDay _azkarMorningTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _azkarEveningTime = const TimeOfDay(hour: 17, minute: 0);

  // Getters
  ScheduleSettings get settings => _settings;
  bool get isDarkMode => _isDarkMode;
  bool get isAzkarReminderEnabled => _isAzkarReminderEnabled;
  TimeOfDay get azkarMorningTime => _azkarMorningTime;
  TimeOfDay get azkarEveningTime => _azkarEveningTime;
  int get playCount => _settingsService.playCount;
  List<(DateTime, String)> get playHistory => _settingsService.playHistory;

  Future<void> init() async {
    await _settingsService.init();
    _settings = await _settingsService.loadSettings();
    _isDarkMode = _settingsService.isDarkMode;

    _isAzkarReminderEnabled = _settingsService.isAzkarReminderEnabled;
    _azkarMorningTime = TimeOfDay(
      hour: _settingsService.azkarMorningHour,
      minute: _settingsService.azkarMorningMinute,
    );
    _azkarEveningTime = TimeOfDay(
      hour: _settingsService.azkarEveningHour,
      minute: _settingsService.azkarEveningMinute,
    );

    if (_isAzkarReminderEnabled) {
      _scheduleAzkarReminders();
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    _isDarkMode = !_isDarkMode;
    await _settingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> updateSettings(ScheduleSettings newSettings) async {
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
    }
    
    notifyListeners();
  }

  Future<void> selectReciter(String reciterId) async {
    _settings = _settings.copyWith(selectedReciterId: reciterId);
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

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

  void _scheduleAzkarReminders() {
    SchedulerService.scheduleAzkarReminders(
      _isAzkarReminderEnabled,
      _azkarMorningTime,
      _azkarEveningTime,
    );
  }
}
