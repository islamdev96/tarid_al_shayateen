import 'package:flutter/material.dart';

/// The type of repeat schedule the user has selected.
enum RepeatMode {
  daily,        // كل يوم
  everyXDays,   // كل X يوم
  weekDays,     // أيام معينة في الأسبوع
}

/// Holds all user scheduling preferences.
class ScheduleSettings {
  final TimeOfDay playbackTime;
  final RepeatMode repeatMode;
  final int intervalDays; // Used when repeatMode == everyXDays
  final Set<int> selectedWeekDays; // 1=Mon..7=Sun, used when repeatMode == weekDays
  final bool isEnabled;
  final String selectedReciterId;
  final DateTime? lastPlayedAt;

  const ScheduleSettings({
    this.playbackTime = const TimeOfDay(hour: 1, minute: 0),
    this.repeatMode = RepeatMode.everyXDays,
    this.intervalDays = 3,
    this.selectedWeekDays = const {1, 4}, // Monday & Thursday by default
    this.isEnabled = false,
    this.selectedReciterId = 'husr',
    this.lastPlayedAt,
  });

  ScheduleSettings copyWith({
    TimeOfDay? playbackTime,
    RepeatMode? repeatMode,
    int? intervalDays,
    Set<int>? selectedWeekDays,
    bool? isEnabled,
    String? selectedReciterId,
    DateTime? lastPlayedAt,
  }) {
    return ScheduleSettings(
      playbackTime: playbackTime ?? this.playbackTime,
      repeatMode: repeatMode ?? this.repeatMode,
      intervalDays: intervalDays ?? this.intervalDays,
      selectedWeekDays: selectedWeekDays ?? this.selectedWeekDays,
      isEnabled: isEnabled ?? this.isEnabled,
      selectedReciterId: selectedReciterId ?? this.selectedReciterId,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  /// Calculates the next scheduled playback time from now.
  DateTime? getNextPlaybackTime() {
    if (!isEnabled) return null;

    final now = DateTime.now();
    final todayPlayback = DateTime(
      now.year, now.month, now.day,
      playbackTime.hour, playbackTime.minute,
    );

    switch (repeatMode) {
      case RepeatMode.daily:
        if (todayPlayback.isAfter(now)) {
          return todayPlayback;
        }
        return todayPlayback.add(const Duration(days: 1));

      case RepeatMode.everyXDays:
        if (lastPlayedAt == null) {
          // First time - schedule for today or tomorrow
          if (todayPlayback.isAfter(now)) {
            return todayPlayback;
          }
          return todayPlayback.add(const Duration(days: 1));
        }
        final nextDate = DateTime(
          lastPlayedAt!.year, lastPlayedAt!.month, lastPlayedAt!.day,
          playbackTime.hour, playbackTime.minute,
        ).add(Duration(days: intervalDays));
        if (nextDate.isAfter(now)) {
          return nextDate;
        }
        // If we missed it, schedule for today or next interval
        if (todayPlayback.isAfter(now)) {
          return todayPlayback;
        }
        return todayPlayback.add(Duration(days: intervalDays));

      case RepeatMode.weekDays:
        if (selectedWeekDays.isEmpty) return null;
        // Find next matching weekday
        for (int i = 0; i < 7; i++) {
          final candidate = todayPlayback.add(Duration(days: i));
          if (selectedWeekDays.contains(candidate.weekday)) {
            if (candidate.isAfter(now)) {
              return candidate;
            }
          }
        }
        // Fallback: next week
        for (int i = 7; i < 14; i++) {
          final candidate = todayPlayback.add(Duration(days: i));
          if (selectedWeekDays.contains(candidate.weekday)) {
            return candidate;
          }
        }
        return null;
    }
  }

  /// Returns a human-readable description of the schedule in Arabic.
  String getScheduleDescription() {
    if (!isEnabled) return 'الجدولة متوقفة';

    final hour = playbackTime.hour;
    final minute = playbackTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$formattedHour:$minute $period';

    switch (repeatMode) {
      case RepeatMode.daily:
        return 'كل يوم الساعة $timeStr';
      case RepeatMode.everyXDays:
        if (intervalDays == 1) return 'كل يوم الساعة $timeStr';
        if (intervalDays == 3) return 'كل ٣ أيام الساعة $timeStr';
        return 'كل $intervalDays أيام الساعة $timeStr';
      case RepeatMode.weekDays:
        final dayNames = {
          1: 'الاثنين',
          2: 'الثلاثاء',
          3: 'الأربعاء',
          4: 'الخميس',
          5: 'الجمعة',
          6: 'السبت',
          7: 'الأحد',
        };
        final days =
            selectedWeekDays.toList()
              ..sort();
        final dayStr = days.map((d) => dayNames[d] ?? '').join(' و ');
        return '$dayStr الساعة $timeStr';
    }
  }
}
