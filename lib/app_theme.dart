import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Islamic-inspired theme manager supporting both light and dark modes.
class AppTheme {
  // --- Dark Mode Color Palette (elnegma-interactive colors) ---
  static const Color primaryGreen = Color(0xFF0D4A2B);   // kept for reference
  static const Color darkGreen = Color(0xFF072A18);
  static const Color deepBackground = Color(0xFF181B24); // Dark Slate
  static const Color cardBackground = Color(0xFF202430); // Muted Slate
  static const Color cardBorder = Color(0x4DB165FB);     // Purple Tinted Border (rgba(177, 101, 251, 0.3))
  static const Color gold = Color(0xFFD4A976);           // Accent Gold
  static const Color goldLight = Color(0xFFE4C39B);      // Light Gold
  static const Color goldDark = Color(0xFF59331F);       // Theme Brown
  static const Color textPrimary = Color(0xFFFFFFFF);    // White
  static const Color textSecondary = Color(0xFFA0AEC0);  // Muted Slate Text
  static const Color textMuted = Color(0x4DA0AEC0);      // Muted Label
  static const Color accentTeal = Color(0xFFB165FB);     // Accent Purple (Primary Accent)
  static const Color accentTealLight = Color(0xFFC78CFC); // Light Accent Purple
  static const Color accentTealDark = Color(0xFF9050DB);  // Dark Accent Purple
  static const Color errorRed = Color(0xFFFF453A);       // Red (Dark)
  static const Color successGreen = Color(0xFF30D158);   // Green (Dark)

  // --- Light Mode Color Palette ---
  static const Color lightBg = Color(0xFFFFFFFF); // Pure White
  static const Color lightBgMid = Color(0xFFFFFFFF); // Pure White
  static const Color lightCardBackground = Color(0x99FFFFFF); // Semi-transparent white card (60% opacity)
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Soft grey border
  static const Color lightTextPrimary = Color(0xFF1E293B); // Deep Slate Grey
  static const Color lightTextSecondary = Color(0xFF475569); // Muted Slate Grey
  static const Color lightTextMuted = Color(0xFF94A3B8); // Soft Slate Grey
  static const Color lightGold = Color(0xFFB88B2E); // Deep gold

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: accentTeal,        // iOS Teal — titles, icons, nav highlights
        onPrimary: deepBackground,
        secondary: gold,            // iOS Orange — play buttons, active tabs
        onSecondary: deepBackground,
        surface: cardBackground,    // iOS Secondary Background
        onSurface: textPrimary,     // iOS Label (pure white)
        error: errorRed,            // iOS Red
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
      scaffoldBackgroundColor: Colors.transparent,
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
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF181B24), // Dark Slate
          Color(0xFF0F1116), // Deep Dark Slate (transitional)
          Color(0xFF181B24), // Dark Slate
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF), // Pure White
          Color(0xFFFFFFFF), // Pure White
          Color(0xFFFFFFFF), // Pure White
        ],
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
