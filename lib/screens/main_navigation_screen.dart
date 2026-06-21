import 'package:flutter/material.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardBackground.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.cardBorder.withValues(alpha: 0.5) : AppTheme.lightCardBorder.withValues(alpha: 0.5),
              width: 1,
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
              icon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'القرآن',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled_rounded),
              label: 'المواقيت',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_rounded),
              label: 'الأذكار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
