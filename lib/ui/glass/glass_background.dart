import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_theme.dart';

class GlassScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,            // مهم: عشان البار يطفو فوق المحتوى
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Base gradient background
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(context),
            ),
          ),
          // Ambient glowing blobs (iOS-style Indigo + Orange)
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF5E5CE6).withValues(alpha: 0.15) // iOS Indigo
                    : const Color(0xFF5856D6).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFFFF9F0A).withValues(alpha: 0.10) // iOS Orange
                    : const Color(0xFFFF9500).withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: 80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF0A84FF).withValues(alpha: 0.10) // iOS Blue
                    : const Color(0xFF007AFF).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFFBF5AF2).withValues(alpha: 0.10) // iOS Purple
                    : const Color(0xFFAF52DE).withValues(alpha: 0.07),
              ),
            ),
          ),
          // Soft backdrop filter overlay to blend the blobs into a mesh
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          // Foreground content
          SafeArea(
            bottom: false,
            child: body,
          ),
        ],
      ),
    );
  }
}
