import 'package:flutter/material.dart';

class GlassTokens {
  // --- Dark Mode (iOS ultraThinMaterial Dark) ---
  static const double cardOpacityDark = 0.12;
  static const double barOpacityDark = 0.16;
  static const double sheetOpacityDark = 0.14;
  static const double softBlurDark = 30.0;
  static const double strongBlurDark = 50.0;
  static const double borderOpacityDark = 0.18;
  static const Color tintDark = Color(0xFFEBEBF5);

  // --- Light Mode (iOS ultraThinMaterial Light) ---
  static const double cardOpacityLight = 0.30;
  static const double barOpacityLight = 0.40;
  static const double sheetOpacityLight = 0.35;
  static const double softBlurLight = 25.0;
  static const double strongBlurLight = 45.0;
  static const double borderOpacityLight = 0.30;
  static const Color tintLight = Color(0xFFF1F5F9);

  // Shared defaults
  static const double radius = 22;
  static const double radiusLarge = 30;

  // Dynamic getters based on brightness
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

  static Color getTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? tintDark : tintLight;
}
