import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfcow/features/settings/presentation/providers/settings_provider.dart';

// Helper class to hold theme references
class AppThemeColors {
  final Color bg;
  final Color panel;
  final Color panel2;
  final Color card;
  final Color stroke;
  final Color stroke2;
  final Color text;
  final Color muted;
  final Color muted2;
  final Color accent;
  final Color accent2;
  final Color warn;
  final Color danger;
  final BoxDecoration backgroundDecoration;
  final LinearGradient glassGradient;

  const AppThemeColors({
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.card,
    required this.stroke,
    required this.stroke2,
    required this.text,
    required this.muted,
    required this.muted2,
    required this.accent,
    required this.accent2,
    required this.warn,
    required this.danger,
    required this.backgroundDecoration,
    required this.glassGradient,
  });
}

final themeColorsProvider = Provider<AppThemeColors>((ref) {
  final settings = ref.watch(settingsProvider);
  final isDark = settings.themeMode == AppThemeMode.dark;

  if (isDark) {
    return const AppThemeColors(
      bg: Color(0xFF0B1020),
      panel: Color(0xFF0F1630),
      panel2: Color(0xFF111B3B),
      card: Color(0xCC0E1531),
      stroke: Color(0xFF23315A),
      stroke2: Color(0xFF2A3B6E),
      text: Color(0xFFE8ECFF),
      muted: Color(0xFFA7B2DE),
      muted2: Color(0xFF7F8BBF),
      accent: Color(0xFF7C5CFF),
      accent2: Color(0xFF22C55E),
      warn: Color(0xFFF59E0B),
      danger: Color(0xFFEF4444),
      backgroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF070A14),
            Color(0xFF0B1020),
          ],
        ),
      ),
      glassGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x0FFFFFFF),
          Color(0x08FFFFFF),
        ],
      ),
    );
  } else {
    return const AppThemeColors(
      bg: Color(0xFFF9FAFB),
      panel: Color(0xFFFFFFFF),
      panel2: Color(0xFFF3F4F6),
      card: Color(0xCCFFFFFF),
      stroke: Color(0xFFE5E7EB),
      stroke2: Color(0xFFD1D5DB),
      text: Color(0xFF111827),
      muted: Color(0xFF6B7280),
      muted2: Color(0xFF9CA3AF),
      accent: Color(0xFF7C5CFF),
      accent2: Color(0xFF22C55E),
      warn: Color(0xFFF59E0B),
      danger: Color(0xFFEF4444),
      backgroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3F4F6),
            Color(0xFFF9FAFB),
          ],
        ),
      ),
      glassGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x0F000000),
          Color(0x08000000),
        ],
      ),
    );
  }
});
