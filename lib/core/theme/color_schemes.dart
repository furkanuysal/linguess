import 'package:flutter/material.dart';

/// Material 3 ColorSchemes
class AppColorSchemes {
  static const seed = Colors.indigo;

  static ColorScheme light = ColorScheme.fromSeed(
    seedColor: const Color(0xFF819A91),
    brightness: Brightness.light,
    surface: const Color(0xFFEEEFE0),
  );

  static ColorScheme dark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF77ABB7),
    brightness: Brightness.dark,
    surface: const Color(0xFF1D3E53),
  );
}
