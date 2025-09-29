import 'package:flutter/material.dart';

BorderSide settingsContentBorderSide(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return BorderSide(
    color: scheme.outline,
    width: 1.5,
    strokeAlign: BorderSide.strokeAlignCenter,
  );
}

InputDecoration authInputDecoration(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    fillColor: scheme.surface,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.error, width: 2),
    ),
  );
}
