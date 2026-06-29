import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_theme.dart';

/// Premium glassmorphic scaffold with animated ambient mesh gradient blobs.
/// Provides the colorful backing required for frosted glass effects.
class GlassScaffold extends StatefulWidget {
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
  State<GlassScaffold> createState() => _GlassScaffoldState();
}

class _GlassScaffoldState extends State<GlassScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: widget.appBar,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: Stack(
        children: [
          // Base gradient background
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(context),
            ),
          ),

          // Animated ambient blobs
          AnimatedBuilder(
            animation: _breathController,
            builder: (context, _) {
              final t = _breathController.value;
              final breathScale = 0.9 + 0.2 * sin(t * pi);

              return Stack(
                children: [
                  // Blob 1: Indigo (top-left)
                  Positioned(
                    top: -100 + 20 * sin(t * pi),
                    left: -60 + 15 * cos(t * pi),
                    child: Transform.scale(
                      scale: breathScale,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF5856D6).withValues(alpha: 0.20)
                              : const Color(0xFF5856D6).withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ),
                  // Blob 2: Cyan (center-right)
                  Positioned(
                    top: 280 + 25 * sin(t * pi * 1.3),
                    right: -40 + 20 * cos(t * pi * 0.8),
                    child: Transform.scale(
                      scale: 1.1 - 0.15 * sin(t * pi),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF5AC8FA).withValues(alpha: 0.16)
                              : const Color(0xFF5AC8FA).withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),
                  // Blob 3: Pink (bottom-left)
                  Positioned(
                    bottom: -60 + 20 * cos(t * pi * 0.9),
                    left: -50 + 15 * sin(t * pi * 1.1),
                    child: Transform.scale(
                      scale: breathScale * 0.95,
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFFFF375F).withValues(alpha: 0.12)
                              : const Color(0xFFFF375F).withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                  ),
                  // Blob 4: Amber (bottom-right)
                  Positioned(
                    bottom: 150 + 18 * sin(t * pi * 1.2),
                    right: -80 + 22 * cos(t * pi * 0.7),
                    child: Transform.scale(
                      scale: 1.0 + 0.1 * cos(t * pi),
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFFFF9F0A).withValues(alpha: 0.10)
                              : const Color(0xFFFF9F0A).withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                  ),
                  // Blob 5: Teal (top-right)
                  Positioned(
                    top: 80 + 12 * cos(t * pi * 1.4),
                    right: 60 + 10 * sin(t * pi),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF40CBE0).withValues(alpha: 0.10)
                            : const Color(0xFF40CBE0).withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Heavy blur to merge blobs into smooth ambient mesh
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Subtle noise-like grain overlay for realism
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.008 : 0.015),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            bottom: false,
            child: widget.body,
          ),
        ],
      ),
    );
  }
}
