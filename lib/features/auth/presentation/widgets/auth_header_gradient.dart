import 'package:flutter/material.dart';

class AuthHeaderGradient extends StatelessWidget {
  const AuthHeaderGradient({super.key, this.height = 320});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Light palette
    const lightColors = <Color>[
      Color(0xFF819A91),
      Color(0xFFA7C1A8),
      Color(0xFFD1D8BE),
      Color(0xFFEEEFE0),
    ];
    const lightStops = <double>[0.0, 0.5, 0.8, 1.0];

    // Dark palette
    const darkColors = <Color>[
      Color(0xFF77ABB7),
      Color(0xFF476D7C),
      Color(0xFF254B62),
      Color(0xFF1D3E53),
    ];
    const darkStops = <double>[0.0, 0.45, 0.8, 1.0];

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? darkColors : lightColors,
          stops: isDark ? darkStops : lightStops,
        ),
      ),
    );
  }
}
