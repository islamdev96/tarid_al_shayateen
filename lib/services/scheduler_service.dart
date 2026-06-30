import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart' if (dart.library.html) 'alarm_manager_stub.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reciter.dart';
import '../models/adhan_sound.dart';
import '../models/prayer_time_settings.dart';
import 'audio_handler.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

/// Callback that fires when morning Azkar alarm triggers.
@pragma('vm:entry-point')
Future<void> morningAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await NotificationService.showNotification(
    id: 222,
    title: 'أذكار الصباح ☀️',
    body: 'حان الآن موعد أذكار الصباح. حصّن نفسك ويومك بذكر الله.',
    payload: 'morning',
  );

  // Reschedule for the next day
  final prefs = await SharedPreferences.getInstance();
  final hour = prefs.getInt('azkar_morning_hour') ?? 6;
  final minute = prefs.getInt('azkar_morning_minute') ?? 30;
  
  final now = DateTime.now();
  var nextTime = DateTime(now.year, now.month, now.day, hour, minute).add(const Duration(days: 1));

  await AndroidAlarmManager.oneShotAt(
    nextTime,
    222, // morningAlarmId
    morningAlarmCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
    allowWhileIdle: true,
  );
}

/// Callback that fires when evening Azkar alarm triggers.
@pragma('vm:entry-point')
Future<void> eveningAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await NotificationService.showNotification(
    id: 333,
    title: 'أذكار المساء 🌙',
    body: 'حان الآن موعد أذكار المساء. حفظك الله من كل سوء ومكروه.',
    payload: 'evening',
  );

  // Reschedule for the next day
  final prefs = await SharedPreferences.getInstance();
  final hour = prefs.getInt('azkar_evening_hour') ?? 17;
  final minute = prefs.getInt('azkar_evening_minute') ?? 0;
  
  final now = DateTime.now();
  var nextTime = DateTime(now.year, now.month, now.day, hour, minute).add(const Duration(days: 1));

  await AndroidAlarmManager.oneShotAt(
    nextTime,
    333, // eveningAlarmId
    eveningAlarmCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
    );
}

/// Callback that fires when any prayer time alarm triggers.
@pragma('vm:entry-point')
Future<void> prayerAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final cityId = prefs.getString('selected_city_id') ?? 'cairo';
  final city = CityConfig.findById(cityId);

  final now = DateTime.now();
  final todayTimes = PrayerTimesService.calculate(city, now);
  final tomorrowTimes = PrayerTimesService.calculate(city, now.add(const Duration(days: 1)));

  final allTimes = [
    ...todayTimes.toList(),
    ...tomorrowTimes.toList(),
  ];

  Map<String, dynamic>? triggeredPrayer;
  double minDiffSeconds = 1e9;
  for (final item in allTimes) {
    final time = item['time'] as DateTime;
    final diff = (time.difference(now).inSeconds).abs();
    if (diff < minDiffSeconds && diff < 900) { // within 15 mins
      minDiffSeconds = diff.toDouble();
      triggeredPrayer = item;
    }
  }

  if (triggeredPrayer != null) {
    final prayerId = triggeredPrayer['id'] as String;
    final prayerName = triggeredPrayer['name'] as String;

    // Check notification setting (default to true for non-sunrise)
    final defaultValue = prayerId != 'sunrise';
    final isNotified = prefs.getBool('prayer_notif_$prayerId') ?? defaultValue;

    if (isNotified) {
      await NotificationService.init();
      final isSunrise = prayerId == 'sunrise';
      final notificationTitle = isSunrise
          ? 'حان الآن وقت شروق الشمس ☀️'
          : 'حان وقت صلاة $prayerName 🕌';
      final notificationBody = isSunrise
          ? 'حان الآن موعد شروق الشمس حسب التوقيت المحلي لمدينة ${city.nameAr}.'
          : 'حان الآن موعد أذان صلاة $prayerName حسب التوقيت المحلي لمدينة ${city.nameAr}.';

      await NotificationService.showNotification(
        id: 444,
        title: notificationTitle,
        body: notificationBody,
        payload: 'prayer_$prayerId',
      );

      final SendPort? sendPort = IsolateNameServer.lookupPortByName('tarid_prayer_port');
      if (sendPort != null) {
        sendPort.send('play_adhan_$prayerId');
      } else {
        try {
          final audioHandler = await AudioService.init(
            builder: () => QuranAudioHandler(),
            config: const AudioServiceConfig(
              androidNotificationChannelId: 'com.islamglab.tarid_al_shayateen.audio',
              androidNotificationChannelName: 'الأذان',
              androidNotificationChannelDescription: 'تشغيل صوت الأذان في وقت الصلاة',
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: true,
            ),
          );

          // Beautiful Adhan per prayer
          final adhanId = prefs.getString('adhan_sound_$prayerId') ?? 
                          (prayerId == 'fajr' ? 'abdulbasit' : (prefs.getString('selected_adhan_id') ?? 'madinah'));
          final adhan = AdhanSound.findById(adhanId);
          final dir = await getApplicationDocumentsDirectory();
          final path = '${dir.path}/adhan_$adhanId.mp3';

          if (await File(path).exists()) {
            await audioHandler.playFromFile(path, adhan.nameAr, surahName: 'أذان صلاة $prayerName');
          } else {
            await audioHandler.playFromUrl(adhan.url, adhan.nameAr, surahName: 'أذان صلاة $prayerName');
          }
        } catch (e) {
          debugPrint('Background playback error: $e');
        }
      }
    }
  }

  // Reschedule next prayer alarm
  await SchedulerService.scheduleNextPrayer(city, isBackground: true);
}

/// Callback that fires when pre-prayer alarm triggers.
@pragma('vm:entry-point')
Future<void> prePrayerAlarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  
  final prefs = await SharedPreferences.getInstance();
  final offset = prefs.getInt('pre_prayer_reminder_offset') ?? 0;
  final type = prefs.getString('pre_prayer_reminder_type') ?? 'notification_only';
  
  // Find out what is the next prayer time (since it's roughly offset minutes away)
  final cityId = prefs.getString('selected_city_id') ?? 'cairo';
  final locationMode = prefs.getString('location_mode') ?? 'manual';
  CityConfig city;
  if (locationMode == 'automatic') {
    final lat = prefs.getDouble('gps_latitude') ?? 30.0444;
    final lng = prefs.getDouble('gps_longitude') ?? 31.2357;
    city = CityConfig(id: 'gps', nameAr: 'الموقع الحالي', nameEn: 'Current Location', latitude: lat, longitude: lng);
  } else {
    city = CityConfig.findById(cityId);
  }

  final nextPrayer = PrayerTimesService.getNextPrayer(city);
  if (nextPrayer != null) {
    final prayerName = nextPrayer['name'] as String;
    final prayerId = nextPrayer['id'] as String;

    final bodyText = 'باقي $offset دقيقة على صلاة $prayerName. تهيأ للوضوء والصلاة.';
    
    // 1. Show notification
    await NotificationService.showNotification(
      id: 555,
      title: 'اقتربت صلاة $prayerName 🕌',
      body: bodyText,
      payload: 'pre_prayer_$prayerId',
    );

    // 2. Play Sound / Speak TTS if requested
    if (type == 'voice_alert') {
      try {
        final SendPort? sendPort = IsolateNameServer.lookupPortByName('tarid_pre_prayer_port');
        if (sendPort != null) {
          sendPort.send('speak_${prayerId}_$offset');
        } else {
          final FlutterTts flutterTts = FlutterTts();
          await flutterTts.setLanguage("ar");
          await flutterTts.setSpeechRate(0.5);
          await flutterTts.speak("اقتربت صلاة $prayerName. باقي $offset دقيقة.");
        }
      } catch (e) {
        debugPrint('Background TTS error: $e');
      }
    } else if (type == 'sound') {
      try {
        final SendPort? sendPort = IsolateNameServer.lookupPortByName('tarid_pre_prayer_port');
        if (sendPort != null) {
          sendPort.send('play_beep');
        } else {
          final audioHandler = await AudioService.init(
            builder: () => QuranAudioHandler(),
            config: const AudioServiceConfig(
              androidNotificationChannelId: 'com.islamglab.tarid_al_shayateen.audio',
              androidNotificationChannelName: 'التنبيهات',
              androidNotificationChannelDescription: 'تنبيهات مواقيت الصلاة',
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: true,
            ),
          );
          await audioHandler.playFromUrl('asset:///assets/transition.mp3', 'تنبيه اقتراب الصلاة', surahName: 'تنبيه');
        }
      } catch (e) {
        debugPrint('Background reminder sound error: $e');
      }
    }
  }
}

/// Manages scheduling periodic alarms to trigger Surah Al-Baqarah playback.
@pragma('vm:entry-point')
class SchedulerService {
  static const int _alarmId = 111; // Non-zero ID to prevent OEM ignorance
  static const int _morningAlarmId = 222;
  static const int _eveningAlarmId = 333;
  static Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await AndroidAlarmManager.initialize();
  }

  /// Schedule the next playback at the given [dateTime].
  static Future<void> scheduleNext(DateTime dateTime, {bool isBackground = false}) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (Platform.isAndroid && !isBackground) {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
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
    if (kIsWeb || !Platform.isAndroid) return;
    await AndroidAlarmManager.cancel(_alarmId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('next_scheduled_time');
  }

  /// Register a port to listen for alarm callbacks from the background isolate.
  static ReceivePort? registerPort() {
    if (kIsWeb) return null;
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

    return false;
  }

  /// Schedule Azkar morning and evening reminders
  static Future<void> scheduleAzkarReminders(
    bool isEnabled,
    TimeOfDay morningTime,
    TimeOfDay eveningTime,
  ) async {
    if (kIsWeb || !Platform.isAndroid) return;
    // Cancel any existing alarms
    await AndroidAlarmManager.cancel(_morningAlarmId);
    await AndroidAlarmManager.cancel(_eveningAlarmId);

    if (!isEnabled) return;

    final now = DateTime.now();

    // 1. Schedule Morning Alarm
    var morningDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      morningTime.hour,
      morningTime.minute,
    );
    if (morningDateTime.isBefore(now)) {
      morningDateTime = morningDateTime.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      morningDateTime,
      _morningAlarmId,
      morningAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );

    // 2. Schedule Evening Alarm
    var eveningDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      eveningTime.hour,
      eveningTime.minute,
    );
    if (eveningDateTime.isBefore(now)) {
      eveningDateTime = eveningDateTime.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      eveningDateTime,
      _eveningAlarmId,
      eveningAlarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
    );
  }

  static const int _prayerAlarmId = 444;
  static const int _prePrayerAlarmId = 555;
  static const String _prayerPortName = 'tarid_prayer_port';

  /// Schedule the next upcoming prayer time alarm.
  static Future<void> scheduleNextPrayer(CityConfig city, {bool isBackground = false}) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (Platform.isAndroid && !isBackground) {
      final status = await Permission.scheduleExactAlarm.status;
      if (!status.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }
    }
    // Cancel any existing prayer alarms
    await AndroidAlarmManager.cancel(_prayerAlarmId);
    await AndroidAlarmManager.cancel(_prePrayerAlarmId);

    final nextPrayer = PrayerTimesService.getNextPrayer(city);
    if (nextPrayer != null) {
      final nextTime = nextPrayer['time'] as DateTime;
      debugPrint('Scheduling next prayer alarm for: ${nextPrayer['name']} at $nextTime');

      await AndroidAlarmManager.oneShotAt(
        nextTime,
        _prayerAlarmId,
        prayerAlarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
      );

      // Schedule pre-prayer alarm
      final prefs = await SharedPreferences.getInstance();
      final offset = prefs.getInt('pre_prayer_reminder_offset') ?? 0;
      if (offset > 0) {
        final preTime = nextTime.subtract(Duration(minutes: offset));
        if (preTime.isAfter(DateTime.now())) {
          debugPrint('Scheduling pre-prayer alarm for: ${nextPrayer['name']} at $preTime ($offset mins before)');
          await AndroidAlarmManager.oneShotAt(
            preTime,
            _prePrayerAlarmId,
            prePrayerAlarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
            allowWhileIdle: true,
          );
        }
      }
    }
  }

  /// Cancel prayer alarms.
  static Future<void> cancelPrayerAlarms() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await AndroidAlarmManager.cancel(_prayerAlarmId);
    await AndroidAlarmManager.cancel(_prePrayerAlarmId);
  }

  /// Register a port to listen for prayer alarm callbacks from the background isolate.
  static ReceivePort? registerPrayerPort() {
    if (kIsWeb) return null;
    IsolateNameServer.removePortNameMapping(_prayerPortName);
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, _prayerPortName);
    return receivePort;
  }
}
