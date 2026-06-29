import 'package:flutter/material.dart';
import '../app_theme.dart';

/// A premium mosque silhouette header widget that overlays at the top of screens.
/// Shows the mosque + night sky in dark mode, and a subtle green-tinted version in light mode.
class MosqueHeaderWidget extends StatelessWidget {
  /// Height of the header image area.
  final double height;

  /// Optional child widget to overlay on top (e.g., app title, date).
  final Widget? child;

  const MosqueHeaderWidget({
    super.key,
    this.height = 200,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          // Background gradient (sky)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0A1929), // Dark navy sky
                        const Color(0xFF081520), // Slightly darker
                        AppTheme.deepBackground, // Blend into page background
                      ]
                    : [
                        AppTheme.lightBg,
                        AppTheme.lightBg,
                      ],
              ),
            ),
          ),

          // Mosque silhouette image
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: isDark ? 0.6 : 0.0,
              child: Image.asset(
                'assets/mosque_header.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: height * 0.85,
                color: isDark ? null : AppTheme.primaryGreen,
                colorBlendMode: isDark ? null : BlendMode.srcIn,
              ),
            ),
          ),

          // Bottom fade to blend into page background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark
                        ? AppTheme.deepBackground
                        : AppTheme.lightBg,
                  ],
                ),
              ),
            ),
          ),

          // Optional child overlay (title, etc.)
          if (child != null)
            Positioned.fill(
              child: child!,
            ),
        ],
      ),
    );
  }
}
