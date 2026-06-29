import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apple-style Glassmorphism theme — iOS 18 / Vision Pro inspired.
class AppTheme {
  // ─── Dark Mode Color Palette (Apple iOS 18 Dark) ───
  static const Color deepBackground = Color(0xFF0A0A0F);    // Deep Space Black
  static const Color cardBackground = Color(0xFF16161E);     // Elevated Surface
  static const Color cardBorder = Color(0x33FFFFFF);          // White 20%
  static const Color accentTeal = Color(0xFF0A84FF);          // iOS System Blue
  static const Color accentTealLight = Color(0xFF5AC8FA);     // iOS Light Blue
  static const Color accentTealDark = Color(0xFF0071E3);      // Apple Deep Blue

  // Keep gold for special elements (play button, featured)
  static const Color gold = Color(0xFFFFD60A);               // iOS Yellow
  static const Color goldLight = Color(0xFFFFE066);
  static const Color goldDark = Color(0xFFC79B1A);

  // Semantic Colors
  static const Color errorRed = Color(0xFFFF453A);           // iOS Red Dark
  static const Color successGreen = Color(0xFF30D158);       // iOS Green Dark

  // Text Colors (Dark)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99EBEBF5);      // 60% iOS Label Secondary
  static const Color textMuted = Color(0x4DEBEBF5);          // 30% iOS Label Tertiary

  // Legacy aliases (keep for compatibility during migration)
  static const Color primaryGreen = Color(0xFF0A84FF);       // Maps to iOS Blue now
  static const Color darkGreen = Color(0xFF0071E3);
  static const Color primaryColor = accentTeal;
  static const Color secondaryColor = gold;
  static const Color darkBackground = deepBackground;

  // ─── Light Mode Color Palette (Apple iOS 18 Light) ───
  static const Color lightBg = Color(0xFFFFFFFF);           // Pure White
  static const Color lightBgMid = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0x99FFFFFF); // 60% white frosted
  static const Color lightCardBorder = Color(0x66FFFFFF);     // 40% white specular
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0x993C3C43); // 60% iOS Label Secondary
  static const Color lightTextMuted = Color(0x4D3C3C43);     // 30% iOS Label Tertiary
  static const Color lightGold = Color(0xFFFF9500);          // iOS Orange Light

  // ─── Glass-specific Constants ───
  static const double glassRadius = 22.0;
  static const double glassRadiusLarge = 30.0;
  static const double pillRadius = 100.0;

  // ─── Dark Theme Configuration ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: accentTeal,
        onPrimary: Colors.white,
        secondary: gold,
        onSecondary: deepBackground,
        surface: cardBackground,
        onSurface: textPrimary,
        error: errorRed,
        onError: textPrimary,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
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
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(glassRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pillRadius)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentTeal,
          side: BorderSide(color: accentTeal.withValues(alpha: 0.5), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pillRadius)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentTeal;
          return cardBorder;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentTeal,
        inactiveTrackColor: cardBorder,
        thumbColor: Colors.white,
        overlayColor: accentTeal.withValues(alpha: 0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        selectedColor: accentTeal.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.cairo(color: textPrimary, fontSize: 13),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 0.5,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(glassRadiusLarge)),
        ),
      ),
    );
  }

  // ─── Light Theme Configuration ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF007AFF),  // iOS Blue Light
        onPrimary: Colors.white,
        secondary: lightGold,
        onSecondary: Colors.white,
        surface: lightCardBackground,
        onSurface: lightTextPrimary,
        error: Color(0xFFFF3B30),    // iOS Red Light
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: lightTextPrimary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: lightTextPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: lightTextPrimary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextSecondary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: lightTextPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: lightTextSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: lightTextMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF007AFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(glassRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pillRadius)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF007AFF),
          side: BorderSide(color: const Color(0xFF007AFF).withValues(alpha: 0.5), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pillRadius)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF34C759);
          return const Color(0xFFE5E5EA);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF007AFF),
        inactiveTrackColor: const Color(0xFFE5E5EA),
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF007AFF).withValues(alpha: 0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        selectedColor: const Color(0xFF007AFF).withValues(alpha: 0.15),
        labelStyle: GoogleFonts.cairo(color: lightTextPrimary, fontSize: 13),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.06),
        thickness: 0.5,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(glassRadiusLarge)),
        ),
      ),
    );
  }

  // ─── Dynamic Helpers ───

  /// Premium background gradient with subtle depth.
  static Gradient backgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F0F18),  // Deep navy
          Color(0xFF0A0A0F),  // Space black
          Color(0xFF0D0D14),  // Midnight
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),  // Pure white
          Color(0xFFFFFFFF),  // Pure white
          Color(0xFFFFFFFF),  // Pure white
        ],
      );
    }
  }

  /// Gold gradient for play buttons and featured elements.
  static LinearGradient get goldGradient => const LinearGradient(
    colors: [Color(0xFFFFD60A), Color(0xFFFF9F0A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// iOS Blue gradient for accent highlights.
  static LinearGradient get cyanGradient => const LinearGradient(
    colors: [Color(0xFF5AC8FA), Color(0xFF0A84FF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Frosted glass card decoration (use GlassContainer for real blur).
  static BoxDecoration glassCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.60),
      borderRadius: BorderRadius.circular(glassRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.80),
        width: 0.5,
      ),
    );
  }

  /// Glowing accent card decoration.
  static BoxDecoration glowingCyanCard(BuildContext context, {Color? glowColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = glowColor ?? (isDark ? accentTeal : const Color(0xFF007AFF));
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.60),
      borderRadius: BorderRadius.circular(glassRadius),
      border: Border.all(
        color: glow.withValues(alpha: isDark ? 0.25 : 0.20),
        width: 0.8,
      ),
    );
  }

  /// Glowing play button decoration.
  static BoxDecoration get glowingPlayButton => BoxDecoration(
    shape: BoxShape.circle,
    gradient: goldGradient,
  );

  /// Pill button decoration for glassmorphic buttons.
  static BoxDecoration pillButton(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? Theme.of(context).colorScheme.primary;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(pillRadius),
      color: c.withValues(alpha: isDark ? 0.18 : 0.12),
      border: Border.all(
        color: c.withValues(alpha: isDark ? 0.30 : 0.25),
        width: 0.8,
      ),
    );
  }
}
