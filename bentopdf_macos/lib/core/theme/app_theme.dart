import 'package:flutter/material.dart';

class AppTheme {
  // Dark theme colors
  static const _darkBackground = Color(0xFF1F2937);
  static const _darkPrimary = Color(0xFF4F46E5);
  static const _darkTextColor = Color(0xFFF3F4F6);
  static const _darkCardColor = Color(0xFF374151);

  // Light theme colors
  static const _lightBackground = Color(0xFFF9FAFB);
  static const _lightPrimary = Color(0xFF4F46E5);
  static const _lightTextColor = Color(0xFF111827);
  static const _lightCardColor = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkPrimary.withValues(alpha: 0.8),
        surface: _darkBackground,
        onPrimary: Colors.white,
        onSurface: _darkTextColor,
      ),
      scaffoldBackgroundColor: _darkBackground,
      cardTheme: CardThemeData(
        color: _darkCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _darkTextColor,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: _darkTextColor, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _darkTextColor, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: _darkTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: _darkTextColor, fontSize: 14),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightPrimary.withValues(alpha: 0.8),
        surface: _lightBackground,
        onPrimary: Colors.white,
        onSurface: _lightTextColor,
      ),
      scaffoldBackgroundColor: _lightBackground,
      cardTheme: CardThemeData(
        color: _lightCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBackground,
        foregroundColor: _lightTextColor,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: _lightTextColor, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _lightTextColor, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: _lightTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: _lightTextColor, fontSize: 14),
      ),
    );
  }
}
