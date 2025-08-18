import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography (Crimson Pro, w700 default).
class AppTypography {
  // Title, subtitle, body, label sizes
  static const double bodyLg = 18;
  static const double bodyMd = 16;
  static const double bodySm = 14;

  static const double headlineLg = 28;
  static const double headlineMd = 24;
  static const double headlineSm = 22;

  static const double titleLg = 20;
  static const double titleMd = 18;
  static const double titleSm = 16;

  static const double labelLg = 16;
  static const double labelMd = 14;
  static const double labelSm = 12;

  static TextTheme textTheme(ColorScheme scheme) {
    // Default styles w700 (bold), Crimson Pro.
    TextStyle base(double size) =>
        GoogleFonts.crimsonPro(fontWeight: FontWeight.w700, fontSize: size);

    return TextTheme(
      // Body
      bodyLarge: base(bodyLg),
      bodyMedium: base(bodyMd),
      bodySmall: base(bodySm),

      // Headline
      headlineLarge: base(headlineLg),
      headlineMedium: base(headlineMd),
      headlineSmall: base(headlineSm),

      // Title
      titleLarge: base(titleLg),
      titleMedium: base(titleMd),
      titleSmall: base(titleSm),

      // Label
      labelLarge: base(labelLg),
      labelMedium: base(labelMd),
      labelSmall: base(labelSm),
    ).apply(
      // Change text colors based on theme
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }
}
