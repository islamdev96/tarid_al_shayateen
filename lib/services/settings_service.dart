import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_settings.dart';

/// Manages persisting and loading user settings via SharedPreferences.
class SettingsService {
  static const _keyPlaybackHour = 'playback_hour';
  static const _keyPlaybackMinute = 'playback_minute';
  static const _keyRepeatMode = 'repeat_mode';
  static const _keyIntervalDays = 'interval_days';
  static const _keySelectedWeekDays = 'selected_week_days';
  static const _keyIsEnabled = 'is_enabled';
  static const _keySelectedReciterId = 'selected_reciter_id';
  static const _keySelectedAdhanId = 'selected_adhan_id';
  static const _keyLastPlayedAt = 'last_played_at';
  static const _keyIsDarkMode = 'is_dark_mode';
  static const _keyIsAzkarReminderEnabled = 'is_azkar_reminder_enabled';
  static const _keyAzkarMorningHour = 'azkar_morning_hour';
  static const _keyAzkarMorningMinute = 'azkar_morning_minute';
  static const _keyAzkarEveningHour = 'azkar_evening_hour';
  static const _keyAzkarEveningMinute = 'azkar_evening_minute';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<ScheduleSettings> loadSettings() async {
    final hour = _prefs.getInt(_keyPlaybackHour) ?? 1;
    final minute = _prefs.getInt(_keyPlaybackMinute) ?? 0;
    final repeatModeIndex = _prefs.getInt(_keyRepeatMode) ?? 1; // everyXDays
    final intervalDays = _prefs.getInt(_keyIntervalDays) ?? 3;
    final weekDaysStr = _prefs.getStringList(_keySelectedWeekDays) ?? ['1', '4'];
    final isEnabled = _prefs.getBool(_keyIsEnabled) ?? false;
    final reciterId = _prefs.getString(_keySelectedReciterId) ?? 'husr';
    final lastPlayedStr = _prefs.getString(_keyLastPlayedAt);

    return ScheduleSettings(
      playbackTime: TimeOfDay(hour: hour, minute: minute),
      repeatMode: RepeatMode.values[repeatModeIndex],
      intervalDays: intervalDays,
      selectedWeekDays: weekDaysStr.map((s) => int.parse(s)).toSet(),
      isEnabled: isEnabled,
      selectedReciterId: reciterId,
      lastPlayedAt:
          lastPlayedStr != null ? DateTime.parse(lastPlayedStr) : null,
    );
  }

  Future<void> saveSettings(ScheduleSettings settings) async {
    await _prefs.setInt(_keyPlaybackHour, settings.playbackTime.hour);
    await _prefs.setInt(_keyPlaybackMinute, settings.playbackTime.minute);
    await _prefs.setInt(_keyRepeatMode, settings.repeatMode.index);
    await _prefs.setInt(_keyIntervalDays, settings.intervalDays);
    await _prefs.setStringList(
      _keySelectedWeekDays,
      settings.selectedWeekDays.map((d) => d.toString()).toList(),
    );
    await _prefs.setBool(_keyIsEnabled, settings.isEnabled);
    await _prefs.setString(_keySelectedReciterId, settings.selectedReciterId);
    if (settings.lastPlayedAt != null) {
      await _prefs.setString(
        _keyLastPlayedAt,
        settings.lastPlayedAt!.toIso8601String(),
      );
    }
  }

  Future<void> updateLastPlayed(DateTime time) async {
    await _prefs.setString(_keyLastPlayedAt, time.toIso8601String());
  }

  /// Increment the total play count.
  Future<int> incrementPlayCount() async {
    final count = (_prefs.getInt('play_count') ?? 0) + 1;
    await _prefs.setInt('play_count', count);
    return count;
  }

  /// Get total play count.
  int get playCount => _prefs.getInt('play_count') ?? 0;

  /// Add a play entry to history log.
  Future<void> addPlayHistory(String reciterName) async {
    final history = _prefs.getStringList('play_history') ?? [];
    final entry = '${DateTime.now().toIso8601String()}|$reciterName';
    history.insert(0, entry); // newest first
    // Keep only last 50 entries
    if (history.length > 50) history.removeLast();
    await _prefs.setStringList('play_history', history);
  }

  /// Get play history as list of (DateTime, reciterName) pairs.
  List<(DateTime, String)> get playHistory {
    final history = _prefs.getStringList('play_history') ?? [];
    return history.map((e) {
      final parts = e.split('|');
      return (DateTime.parse(parts[0]), parts.length > 1 ? parts[1] : '');
    }).toList();
  }

  /// Get current theme mode (defaults to true for dark mode).
  bool get isDarkMode => _prefs.getBool(_keyIsDarkMode) ?? true;

  /// Save theme mode preference.
  Future<void> setDarkMode(bool val) async {
    await _prefs.setBool(_keyIsDarkMode, val);
  }

  /// Get whether Azkar reminders are enabled (defaults to true)
  bool get isAzkarReminderEnabled => _prefs.getBool(_keyIsAzkarReminderEnabled) ?? true;

  /// Save Azkar reminders enabled status
  Future<void> setAzkarReminderEnabled(bool val) async {
    await _prefs.setBool(_keyIsAzkarReminderEnabled, val);
  }

  /// Get morning Azkar reminder hour (defaults to 6)
  int get azkarMorningHour => _prefs.getInt(_keyAzkarMorningHour) ?? 6;

  /// Save morning Azkar reminder hour
  Future<void> setAzkarMorningHour(int val) async {
    await _prefs.setInt(_keyAzkarMorningHour, val);
  }

  /// Get morning Azkar reminder minute (defaults to 30)
  int get azkarMorningMinute => _prefs.getInt(_keyAzkarMorningMinute) ?? 30;

  /// Save morning Azkar reminder minute
  Future<void> setAzkarMorningMinute(int val) async {
    await _prefs.setInt(_keyAzkarMorningMinute, val);
  }

  /// Get evening Azkar reminder hour (defaults to 17 - 5:00 PM)
  int get azkarEveningHour => _prefs.getInt(_keyAzkarEveningHour) ?? 17;

  /// Save evening Azkar reminder hour
  Future<void> setAzkarEveningHour(int val) async {
    await _prefs.setInt(_keyAzkarEveningHour, val);
  }

  /// Get evening Azkar reminder minute (defaults to 0)
  int get azkarEveningMinute => _prefs.getInt(_keyAzkarEveningMinute) ?? 0;

  /// Save evening Azkar reminder minute
  Future<void> setAzkarEveningMinute(int val) async {
    await _prefs.setInt(_keyAzkarEveningMinute, val);
  }

  /// Get selected city ID (defaults to 'cairo')
  String get selectedCityId => _prefs.getString('selected_city_id') ?? 'cairo';

  /// Save selected city ID
  Future<void> setSelectedCityId(String cityId) async {
    await _prefs.setString('selected_city_id', cityId);
  }

  /// Get whether notification is enabled for a specific prayer
  bool getPrayerNotification(String prayerId) {
    final defaultValue = prayerId != 'sunrise';
    return _prefs.getBool('prayer_notif_$prayerId') ?? defaultValue;
  }

  /// Save whether notification is enabled for a specific prayer
  Future<void> setPrayerNotification(String prayerId, bool val) async {
    await _prefs.setBool('prayer_notif_$prayerId', val);
  }

  /// Get selected Adhan ID (defaults to 'madinah')
  String get selectedAdhanId => _prefs.getString(_keySelectedAdhanId) ?? 'madinah';

  /// Save selected Adhan ID
  Future<void> setSelectedAdhanId(String adhanId) async {
    await _prefs.setString(_keySelectedAdhanId, adhanId);
  }
}
