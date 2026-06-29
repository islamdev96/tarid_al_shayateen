import 'package:flutter/material.dart';

/// Design tokens for Apple-style glassmorphism effects.
/// Based on iOS ultraThinMaterial / regularMaterial specs.
class GlassTokens {
  // ─── Dark Mode (iOS ultraThinMaterial Dark) ───
  static const double cardOpacityDark = 0.08;
  static const double barOpacityDark = 0.12;
  static const double sheetOpacityDark = 0.10;
  static const double softBlurDark = 40.0;
  static const double strongBlurDark = 60.0;
  static const double borderOpacityDark = 0.12;
  static const double innerGlowOpacityDark = 0.04;
  static const double specularOpacityDark = 0.18;
  static const Color tintDark = Color(0xFFEBEBF5);

  // ─── Light Mode (iOS ultraThinMaterial Light) ───
  static const double cardOpacityLight = 0.55;
  static const double barOpacityLight = 0.65;
  static const double sheetOpacityLight = 0.60;
  static const double softBlurLight = 30.0;
  static const double strongBlurLight = 50.0;
  static const double borderOpacityLight = 0.70;
  static const double innerGlowOpacityLight = 0.08;
  static const double specularOpacityLight = 0.50;
  static const Color tintLight = Color(0xFFFFFFFF);

  // ─── Shared Radii ───
  static const double radius = 22;
  static const double radiusLarge = 30;
  static const double radiusPill = 100;

  // ─── Shadow Tokens ───
  static const double ambientShadowBlur = 28;
  static const double crispShadowBlur = 8;
  static const double floatingElevation = 12;

  // ─── Animation Tokens ───
  static const Duration fastDuration = Duration(milliseconds: 180);
  static const Duration normalDuration = Duration(milliseconds: 280);
  static const Duration slowDuration = Duration(milliseconds: 450);
  static const Curve defaultCurve = Curves.easeOutCubic;

  // ─── Dynamic Getters ───
  static double getCardOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardOpacityDark : cardOpacityLight;

  static double getBarOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? barOpacityDark : barOpacityLight;

  static double getSheetOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? sheetOpacityDark : sheetOpacityLight;

  static double getSoftBlur(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? softBlurDark : softBlurLight;

  static double getStrongBlur(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? strongBlurDark : strongBlurLight;

  static double getBorderOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderOpacityDark : borderOpacityLight;

  static double getInnerGlowOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? innerGlowOpacityDark : innerGlowOpacityLight;

  static double getSpecularOpacity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? specularOpacityDark : specularOpacityLight;

  static Color getTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? tintDark : tintLight;
}
