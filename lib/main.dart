import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'providers/app_provider.dart';
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
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(_audioHandler),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              title: 'سَكينة',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              scrollBehavior: const IosScrollBehavior(),
              locale: const Locale('ar', 'SA'),
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}

