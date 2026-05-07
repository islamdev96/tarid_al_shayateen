import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reciter.dart';
import 'audio_handler.dart';

const String _portName = 'tarid_alarm_port';

/// The callback that fires when the alarm triggers.
/// This MUST be a top-level function to avoid DartVM errors in the background isolate.
@pragma('vm:entry-point')
Future<void> alarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mark the time of triggering
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_alarm_trigger', DateTime.now().toIso8601String());
  await prefs.setBool('alarm_triggered', true);
  await prefs.remove('next_scheduled_time');

  // Send message to main isolate to start playback
  final SendPort? sendPort = IsolateNameServer.lookupPortByName(_portName);
  if (sendPort != null) {
    sendPort.send('play');
  } else {
    // Main app is dead, initialize AudioService and play directly
    try {
      final audioHandler = await AudioService.init(
        builder: () => QuranAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.islamglab.tarid_al_shayateen.audio',
          androidNotificationChannelName: 'سورة البقرة',
          androidNotificationChannelDescription: 'تشغيل سورة البقرة',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      final reciterId = prefs.getString('selected_reciter_id') ?? 'husr';
      final reciter = Reciter.findById(reciterId);

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/surah_baqarah_$reciterId.mp3';

      if (await File(path).exists()) {
        await audioHandler.playFromFile(path, reciter.nameAr);
      } else if (reciter.isOffline) {
        bool found = false;
        for (final r in Reciter.defaultReciters) {
          final fallbackPath = '${dir.path}/surah_baqarah_${r.id}.mp3';
          if (await File(fallbackPath).exists()) {
            await audioHandler.playFromFile(fallbackPath, 'سورة البقرة - نسخة محفوظة');
            found = true;
            break;
          }
        }
        if (!found) {
          await audioHandler.playFromUrl(reciter.surahBaqarahUrl, reciter.nameAr);
        }
      } else {
        await audioHandler.playFromUrl(reciter.surahBaqarahUrl, reciter.nameAr);
      }
    } catch (e) {
      debugPrint('Background playback error: $e');
    }
  }
}

/// Manages scheduling periodic alarms to trigger Surah Al-Baqarah playback.
class SchedulerService {
  static const int _alarmId = 111; // Non-zero ID to prevent OEM ignorance
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule the next playback at the given [dateTime].
  static Future<void> scheduleNext(DateTime dateTime) async {
    if (Platform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }
    // Cancel any existing alarm
    await AndroidAlarmManager.cancel(_alarmId);

    // Save the scheduled time for fallback check
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('next_scheduled_time', dateTime.toIso8601String());

    await AndroidAlarmManager.oneShotAt(
      dateTime,
      _alarmId,
      alarmCallback,
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
