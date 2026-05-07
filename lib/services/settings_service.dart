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
  static const _keyLastPlayedAt = 'last_played_at';

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
    final isEnabled = _prefs.getBool(_keyIsEnabled) ?? true;
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
}
