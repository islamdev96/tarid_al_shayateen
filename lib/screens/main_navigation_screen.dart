import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/mini_player_widget.dart';
import '../ui/glass/glass_bottom_bar.dart';
import '../ui/app_icons.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'prayer_times_screen.dart';
import 'azkar_screen.dart';
import 'settings_screen.dart';

/// Container screen that manages tabs navigation and the global MiniPlayer.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    QuranScreen(),
    PrayerTimesScreen(),
    AzkarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the screens to scroll behind the navigation bar and mini player
      body: Stack(
        children: [
          // Current active screen
          _screens[_currentIndex],
          
          // Floating Mini Player docked above BottomNavigationBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 104, // Perfectly positioned above the floating GlassBottomBar
            child: const MiniPlayerWidget(),
          ),
        ],
      ),
      bottomNavigationBar: GlassBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        icons: const [
          AppIcons.home,
          AppIcons.quran,
          AppIcons.prayerTimes,
          AppIcons.azkar,
          AppIcons.settings,
        ],
      ),
    );
  }
}
