import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../app_theme.dart';
import '../widgets/mini_player_widget.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            bottom: kBottomNavigationBarHeight + 16,
            child: const MiniPlayerWidget(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xFF0C1921).withValues(alpha: 0.5) 
                  : Colors.white.withValues(alpha: 0.5),
              border: Border(
                top: BorderSide(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.08) 
                      : AppTheme.lightCardBorder.withValues(alpha: 0.25),
                  width: 0.5, // Thin iOS border line
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Cairo'),
              unselectedLabelStyle: const TextStyle(fontSize: 10, fontFamily: 'Cairo'),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.house),
                  activeIcon: Icon(CupertinoIcons.house_fill),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.book),
                  activeIcon: Icon(CupertinoIcons.book_fill),
                  label: 'القرآن',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.clock),
                  activeIcon: Icon(CupertinoIcons.clock_fill),
                  label: 'المواقيت',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.shield),
                  activeIcon: Icon(CupertinoIcons.shield_fill),
                  label: 'الأذكار',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.settings),
                  activeIcon: Icon(CupertinoIcons.settings_solid),
                  label: 'الإعدادات',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
