import 'package:flutter/material.dart';

class PdfEditorTheme {
  // Background colors
  static const Color bg = Color(0xFF0B1020);
  static const Color panel = Color(0xFF0F1630);
  static const Color panel2 = Color(0xFF111B3B);
  static const Color card = Color(0xCC0E1531);

  // Border/Stroke colors
  static const Color stroke = Color(0xFF23315A);
  static const Color stroke2 = Color(0xFF2A3B6E);

  // Text colors
  static const Color text = Color(0xFFE8ECFF);
  static const Color muted = Color(0xFFA7B2DE);
  static const Color muted2 = Color(0xFF7F8BBF);

  // Accent colors
  static const Color accent = Color(0xFF7C5CFF);
  static const Color accent2 = Color(0xFF22C55E);
  static const Color warn = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Dimensions
  static const double radius = 18.0;
  static const double radius2 = 14.0;
  static const double blur = 18.0;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF27C5CFF),
      Color(0x8C7C5CFF),
    ],
  );

  static const LinearGradient goodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEB22C55E),
      Color(0x8C22C55E),
    ],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x0FFFFFFF),
      Color(0x08FFFFFF),
    ],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 60,
      offset: const Offset(0, 20),
    ),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: accent.withOpacity(0.18),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get goodShadow => [
    BoxShadow(
      color: accent2.withOpacity(0.14),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
  ];

  // Background decoration
  static BoxDecoration get backgroundDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF070A14),
        bg,
      ],
    ),
  );

  // Glass panel decoration
  static BoxDecoration get glassPanelDecoration => BoxDecoration(
    gradient: glassGradient,
    border: Border.all(
      color: Colors.white.withOpacity(0.10),
      width: 1,
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: cardShadow,
  );

  // Button styles
  static BoxDecoration buttonDecoration({
    bool isActive = false,
    bool isPrimary = false,
    bool isGood = false,
  }) {
    if (isPrimary) {
      return BoxDecoration(
        gradient: primaryGradient,
        border: Border.all(
          color: accent.withOpacity(0.45),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: accentShadow,
      );
    }

    if (isGood) {
      return BoxDecoration(
        gradient: goodGradient,
        border: Border.all(
          color: accent2.withOpacity(0.45),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: goodShadow,
      );
    }

    if (isActive) {
      return BoxDecoration(
        color: accent.withOpacity(0.14),
        border: Border.all(
          color: accent.withOpacity(0.55),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius2),
      );
    }

    return BoxDecoration(
      color: Colors.black.withOpacity(0.18),
      border: Border.all(
        color: Colors.white.withOpacity(0.10),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(radius2),
    );
  }

  // Tool button decoration
  static BoxDecoration toolDecoration({bool isActive = false}) {
    if (isActive) {
      return BoxDecoration(
        color: accent.withOpacity(0.14),
        border: Border.all(
          color: accent.withOpacity(0.55),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }

    return BoxDecoration(
      color: Colors.black.withOpacity(0.18),
      border: Border.all(
        color: Colors.white.withOpacity(0.10),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    color: text,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: text,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle mutedStyle = TextStyle(
    color: muted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonStyle = TextStyle(
    color: text,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}
