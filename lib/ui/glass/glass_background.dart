import 'dart:ui';
import 'package:flutter/material.dart';

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B1035), // بنفسجي غامق
                  Color(0xFF24305E), // أزرق
                  Color(0xFF3A1C4D), // بنفسجي
                ],
              ),
            ),
          ),
          // Ambient glowing blobs
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C8CFF).withValues(alpha: 0.12),
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
                color: const Color(0xFFFF7F32).withValues(alpha: 0.08),
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
