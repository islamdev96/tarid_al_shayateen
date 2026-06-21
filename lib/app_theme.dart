import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Islamic-inspired theme manager supporting both light and dark modes.
class AppTheme {
  // --- Dark Mode Color Palette ---
  static const Color primaryGreen = Color(0xFF0D4A2B);
  static const Color darkGreen = Color(0xFF072A18);
  static const Color deepBackground = Color(0xFF040F09);
  static const Color cardBackground = Color(0xFF0A2E1A);
  static const Color cardBorder = Color(0xFF1A5C3A);
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color goldDark = Color(0xFFB88B2E);
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFFA8C4B0);
  static const Color textMuted = Color(0xFF6B8F78);
  static const Color accentTeal = Color(0xFF2EC4A0);
  static const Color errorRed = Color(0xFFE85454);
  static const Color successGreen = Color(0xFF4CAF50);

  // --- Light Mode Color Palette ---
  static const Color lightBg = Color(0xFFFCFAF6); // Soft warm white/cream
  static const Color lightBgMid = Color(0xFFF5EFE4); // Soft beige
  static const Color lightCardBackground = Color(0xFFF3ECE0); // Cream card
  static const Color lightCardBorder = Color(0xFFE2D6C1); // Soft gold/beige border
  static const Color lightTextPrimary = Color(0xFF163220); // Deep green
  static const Color lightTextSecondary = Color(0xFF385E46); // Muted green
  static const Color lightTextMuted = Color(0xFF6B8A75); // Lighter muted green
  static const Color lightGold = Color(0xFFB88B2E); // Deep gold

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepBackground,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        onPrimary: deepBackground,
        secondary: accentTeal,
        onSecondary: deepBackground,
        surface: cardBackground,
        onSurface: textPrimary,
        error: errorRed,
        onError: textPrimary,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: gold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textSecondary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: gold),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: gold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: deepBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gold,
          side: const BorderSide(color: gold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return gold;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gold.withValues(alpha: 0.3);
          }
          return cardBorder;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: gold,
        inactiveTrackColor: cardBorder,
        thumbColor: gold,
        overlayColor: gold.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardBackground,
        selectedColor: gold.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.cairo(color: textPrimary, fontSize: 13),
        side: const BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 0.5,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: lightGold,
        onPrimary: lightBg,
        secondary: primaryGreen,
        onSecondary: Colors.white,
        surface: lightCardBackground,
        onSurface: lightTextPrimary,
        error: errorRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: lightTextPrimary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightTextPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: lightGold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextSecondary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: lightTextPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: lightTextSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: lightTextMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: lightGold),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightGold,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightCardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGold,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightGold,
          side: const BorderSide(color: lightGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return lightGold;
          return lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightGold.withValues(alpha: 0.3);
          }
          return lightCardBorder;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: lightGold,
        inactiveTrackColor: lightCardBorder,
        thumbColor: lightGold,
        overlayColor: lightGold.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCardBackground,
        selectedColor: lightGold.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.cairo(color: lightTextPrimary, fontSize: 13),
        side: const BorderSide(color: lightCardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: lightCardBorder,
        thickness: 0.5,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  /// Dynamic background gradient based on active theme.
  static Gradient backgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [deepBackground, Color(0xFF061A0F), deepBackground],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightBg, lightBgMid, lightBg],
      );
    }
  }

  /// Dynamic gold gradient.
  static LinearGradient get goldGradient => const LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dynamic glass card decoration based on active theme.
  static BoxDecoration glassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? cardBackground.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? cardBorder.withValues(alpha: 0.5) : lightCardBorder.withValues(alpha: 0.7),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Glowing play button decoration.
  static BoxDecoration get glowingPlayButton => BoxDecoration(
    shape: BoxShape.circle,
    gradient: goldGradient,
    boxShadow: [
      BoxShadow(
        color: gold.withValues(alpha: 0.4),
        blurRadius: 24,
        spreadRadius: 2,
      ),
    ],
  );
}
