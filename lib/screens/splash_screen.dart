import 'dart:async';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _shieldController;
  late AnimationController _fadeController;
  late AnimationController _textController;
  late Animation<double> _shieldScale;
  late Animation<double> _shieldGlow;
  late Animation<double> _fadeIn;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Shield scale + glow animation
    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shieldScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.elasticOut),
    );
    _shieldGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeOut),
    );

    // Background fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _shieldController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeIn,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient(context),
            ),
            child: Center(
              child: Opacity(
                opacity: _fadeIn.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bismillah
                    FadeTransition(
                      opacity: _textFade,
                      child: const Text(
                        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.gold,
                          fontFamily: 'serif',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Shield icon with glow
                    AnimatedBuilder(
                      animation: _shieldController,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _shieldScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.gold.withValues(
                                    alpha: 0.4 * _shieldGlow.value,
                                  ),
                                  blurRadius: 40 * _shieldGlow.value,
                                  spreadRadius: 8 * _shieldGlow.value,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield_rounded,
                              size: 56,
                              color: AppTheme.deepBackground,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // App name
                    FadeTransition(
                      opacity: _textFade,
                      child: const Text(
                        'طارد الشياطين',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    FadeTransition(
                      opacity: _textFade,
                      child: Text(
                        'سورة البقرة حصنك من الشيطان',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
