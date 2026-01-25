import 'package:flutter/material.dart';

class AppTheme {
  static const _darkBackground = Color(0xFF1F2937);
  static const _primary = Color(0xFF4F46E5);
  static const _textColor = Color(0xFFF3F4F6);
  static const _cardColor = Color(0xFF374151);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primary,
        secondary: _primary.withValues(alpha: 0.8),
        surface: _darkBackground,
        onPrimary: Colors.white,
        onSurface: _textColor,
      ),
      scaffoldBackgroundColor: _darkBackground,
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        foregroundColor: _textColor,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: _textColor, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: _textColor, fontSize: 16),
        bodyMedium: TextStyle(color: _textColor, fontSize: 14),
      ),
    );
  }
}
