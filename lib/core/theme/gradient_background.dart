import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.55, 1.0],
          colors: [
            scheme.surfaceContainerHigh,
            scheme.surface,
            scheme.surfaceContainerHighest,
          ],
        ),
      ),
    );
  }
}

class SheetBackground extends StatelessWidget {
  const SheetBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.55, 1.0],
            colors: [
              scheme.surfaceContainerHigh,
              scheme.surface,
              scheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
