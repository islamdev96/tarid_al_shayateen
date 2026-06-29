import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/prayer_times_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/download_provider.dart';
import 'screens/splash_screen.dart';
import 'services/audio_handler.dart';
import 'services/scheduler_service.dart';
import 'services/notification_service.dart';

late QuranAudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.deepBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize AudioService with our custom handler
  _audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.islamglab.tarid_al_shayateen.audio',
      androidNotificationChannelName: 'سورة البقرة',
      androidNotificationChannelDescription: 'تشغيل سورة البقرة',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  // Initialize alarm scheduler
  await SchedulerService.init();

  // Initialize notification service
  await NotificationService.init();

  runApp(const TaridApp());
}

class IosScrollBehavior extends ScrollBehavior {
  const IosScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class TaridApp extends StatelessWidget {
  const TaridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()..init()),
        ChangeNotifierProvider(create: (_) => AudioProvider()..init(_audioHandler)),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()..autoDownloadOffline()),
        ChangeNotifierProvider(create: (_) => AppProvider()..init(_audioHandler)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'سَكينة',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            scrollBehavior: const IosScrollBehavior(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
            ],
            locale: const Locale('ar', 'SA'),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

