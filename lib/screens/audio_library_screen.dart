import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import '../app_theme.dart';
import 'quran_screen.dart';
import 'radio_screen.dart';

class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        appBar: AppBar(
          title: const Text('المكتبة الصوتية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to downloads
                },
                icon: const Icon(CupertinoIcons.cloud_download, size: 18),
                label: const Text('الأصوات المحملة', style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.darkBackground,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStarButton(
                  context,
                  title: 'القرآن الكريم',
                  icon: CupertinoIcons.book_circle_fill,
                  onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const QuranScreen())),
                ),
                const SizedBox(height: 60),
                _buildStarButton(
                  context,
                  title: 'إذاعة القرآن',
                  icon: CupertinoIcons.radiowaves_right,
                  onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const RadioScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarButton(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),
                Icon(icon, size: 60, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 2))],
            ),
          ),
        ],
      ),
    );
  }
}
