import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages scheduling periodic alarms to trigger Surah Al-Baqarah playback.
class SchedulerService {
  static const int _alarmId = 0;
  static const String _portName = 'tarid_alarm_port';

  /// Initialize the alarm manager.
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule the next playback at the given [dateTime].
  static Future<void> scheduleNext(DateTime dateTime) async {
    // Cancel any existing alarm
    await AndroidAlarmManager.cancel(_alarmId);

    // Save the scheduled time for fallback check
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('next_scheduled_time', dateTime.toIso8601String());

    await AndroidAlarmManager.oneShotAt(
      dateTime,
      _alarmId,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );
  }

  /// Cancel all scheduled alarms.
  static Future<void> cancelAll() async {
    await AndroidAlarmManager.cancel(_alarmId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('next_scheduled_time');
  }

  /// The callback that fires when the alarm triggers.
  /// This runs in a separate isolate, so it communicates via IsolateNameServer.
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    // Mark the time of triggering
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_alarm_trigger', DateTime.now().toIso8601String());
    await prefs.setBool('alarm_triggered', true);
    await prefs.remove('next_scheduled_time');

    // Send message to main isolate to start playback
    final SendPort? sendPort = IsolateNameServer.lookupPortByName(_portName);
    sendPort?.send('play');
  }

  /// Register a port to listen for alarm callbacks from the background isolate.
  static ReceivePort registerPort() {
    // Remove any existing port
    IsolateNameServer.removePortNameMapping(_portName);

    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, _portName);
    return receivePort;
  }

  /// Check if an alarm was triggered while the app was closed.
  /// Returns true if a pending alarm was found and should be played now.
  static Future<bool> checkPendingAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final triggered = prefs.getBool('alarm_triggered') ?? false;
    if (triggered) {
      await prefs.setBool('alarm_triggered', false);
      return true;
    }

    // Also check if scheduled time has passed (fallback)
    final scheduledStr = prefs.getString('next_scheduled_time');
    if (scheduledStr != null) {
      final scheduled = DateTime.parse(scheduledStr);
      if (DateTime.now().isAfter(scheduled)) {
        await prefs.remove('next_scheduled_time');
        return true;
      }
    }

    return false;
  }
}
