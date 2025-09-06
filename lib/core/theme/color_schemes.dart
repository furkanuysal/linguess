import 'package:flutter/material.dart';

/// Material 3 ColorSchemes
class AppColorSchemes {
  static const seed = Colors.indigo;

  static ColorScheme light = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  static ColorScheme dark = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );
}
