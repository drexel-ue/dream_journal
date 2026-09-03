import 'package:flutter/material.dart';

class CosmicColors {
  static const Color background = Color(0xFF0A0B1A);
  static const Color backgroundSecondary = Color(0xFF12132C);
  static const Color cardSurface = Color(0xFF191B3B);
  static const Color cardSurfaceHover = Color(0xFF232552);

  static const Color borderLight = Color(0x338B5CF6);
  static const Color borderSubtle = Color(0x22FFFFFF);

  // Celestial Accents
  static const Color astralViolet = Color(0xFF8B5CF6);
  static const Color lucidPurple = Color(0xFFA855F7);
  static const Color celestialCyan = Color(0xFF06B6D4);
  static const Color starlightGold = Color(0xFFF59E0B);
  static const Color auraPink = Color(0xFFEC4899);
  static const Color dreamEmerald = Color(0xFF10B981);
  static const Color cosmicRed = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class CosmicTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CosmicColors.background,
      primaryColor: CosmicColors.astralViolet,
      canvasColor: CosmicColors.backgroundSecondary,
      cardColor: CosmicColors.cardSurface,
      dividerColor: CosmicColors.borderSubtle,
      colorScheme: const ColorScheme.dark(
        primary: CosmicColors.astralViolet,
        secondary: CosmicColors.celestialCyan,
        tertiary: CosmicColors.starlightGold,
        surface: CosmicColors.cardSurface,
        onPrimary: Colors.white,
        onSurface: CosmicColors.textPrimary,
      ),
      fontFamily: 'PlusJakartaSans',
      textTheme: baseTextTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: CosmicColors.textPrimary,
          letterSpacing: 1.2,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: CosmicColors.textPrimary,
          letterSpacing: 1.1,
        ),
        displaySmall: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CosmicColors.textPrimary,
          letterSpacing: 1.0,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CosmicColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CosmicColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: CosmicColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: CosmicColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: CosmicColors.textSecondary,
          height: 1.4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CosmicColors.cardSurface.withOpacity(0.6),
        hintStyle: const TextStyle(color: CosmicColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: CosmicColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CosmicColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CosmicColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CosmicColors.astralViolet, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CosmicColors.cardSurface,
        selectedColor: CosmicColors.astralViolet.withOpacity(0.35),
        disabledColor: Colors.transparent,
        labelStyle: const TextStyle(color: CosmicColors.textPrimary, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CosmicColors.borderSubtle),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: CosmicColors.textPrimary),
      ),
    );
  }
}
