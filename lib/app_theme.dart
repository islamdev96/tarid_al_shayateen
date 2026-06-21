import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Islamic-inspired theme manager supporting both light and dark modes.
class AppTheme {
  // --- Dark Mode Color Palette ---
  static const Color primaryGreen = Color(0xFF0D4A2B);
  static const Color darkGreen = Color(0xFF072A18);
  static const Color deepBackground = Color(0xFF060F14); // Ultra-dark slate blue/black
  static const Color cardBackground = Color(0xFF0D1B24); // Dark slate card
  static const Color cardBorder = Color(0xFF1B313F);     // Slate border
  static const Color gold = Color(0xFFFF7F32);           // Vibrant orange accent (play buttons, active tabs)
  static const Color goldLight = Color(0xFFFF9E63);      // Light orange
  static const Color goldDark = Color(0xFFD65C12);       // Dark orange
  static const Color textPrimary = Color(0xFFF0F4F8);    // Crisp white-slate text
  static const Color textSecondary = Color(0xFF8EA1A8);  // Muted slate text
  static const Color textMuted = Color(0xFF556972);      // Dark muted text
  static const Color accentTeal = Color(0xFF00BCD4);     // ✅ REAL cyan/teal (titles, icons, nav, glowing borders)
  static const Color accentTealLight = Color(0xFF4DD0E1); // Light cyan
  static const Color accentTealDark = Color(0xFF0097A7);  // Dark cyan
  static const Color errorRed = Color(0xFFE85454);
  static const Color successGreen = Color(0xFF4CAF50);

  // --- Light Mode Color Palette ---
  static const Color lightBg = Color(0xFFFAF8F5); // Warm Pearl/Cream
  static const Color lightBgMid = Color(0xFFF0EAE1); // Warm sand
  static const Color lightCardBackground = Color(0xFFF7F3EC); // Soft clean cream card
  static const Color lightCardBorder = Color(0xFFE2DBCF); // Soft sand border
  static const Color lightTextPrimary = Color(0xFF11261B); // Very deep emerald/charcoal
  static const Color lightTextSecondary = Color(0xFF385243); // Muted deep green
  static const Color lightTextMuted = Color(0xFF6F8978); // Soft sage green
  static const Color lightGold = Color(0xFFB88B2E); // Deep gold

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentTeal,       // Cyan for titles, icons, nav highlights
        onPrimary: deepBackground,
        secondary: gold,           // Orange for play buttons, active tabs
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
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: accentTeal),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textSecondary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accentTeal),
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
          color: accentTeal,
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
          backgroundColor: accentTeal,
          foregroundColor: deepBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentTeal,
          side: const BorderSide(color: accentTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentTeal;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentTeal.withValues(alpha: 0.3);
          }
          return cardBorder;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentTeal,
        inactiveTrackColor: cardBorder,
        thumbColor: accentTeal,
        overlayColor: accentTeal.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardBackground,
        selectedColor: accentTeal.withValues(alpha: 0.2),
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
        primary: primaryGreen, // Beautiful deep green as primary
        onPrimary: Colors.white,
        secondary: lightGold,
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
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primaryGreen), // Emerald green instead of yellow
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextSecondary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: lightTextPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: lightTextSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: lightTextMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryGreen),
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
          color: primaryGreen, // Deep green appbar title
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
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGreen;
          return lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGreen.withValues(alpha: 0.3);
          }
          return lightCardBorder;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: lightCardBorder,
        thumbColor: primaryGreen,
        overlayColor: primaryGreen.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCardBackground,
        selectedColor: primaryGreen.withValues(alpha: 0.15),
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
        colors: [deepBackground, Color(0xFF0B1B24), deepBackground],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightBg, lightBgMid, lightBg],
      );
    }
  }

  /// Dynamic gold/orange gradient (for play buttons, active tabs).
  static LinearGradient get goldGradient => const LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dynamic cyan gradient (for countdown cards, splash, highlights).
  static LinearGradient get cyanGradient => const LinearGradient(
    colors: [accentTealDark, accentTeal, accentTealLight],
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

  /// Glowing cyan card decoration for dark mode feature cards.
  static BoxDecoration glowingCyanCard(BuildContext context, {Color? glowColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = glowColor ?? accentTeal;
    return BoxDecoration(
      color: isDark ? cardBackground.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? glow.withValues(alpha: 0.3) : lightCardBorder.withValues(alpha: 0.7),
        width: isDark ? 1.2 : 1,
      ),
      boxShadow: [
        if (isDark)
          BoxShadow(
            color: glow.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Glowing play button decoration (orange/gold).
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
