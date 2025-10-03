import 'package:flutter/material.dart';

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradient = LinearGradient(
      colors: [scheme.surface, scheme.surfaceContainerHigh],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Top left icon skeleton
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Top right progress skeleton
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: scheme.primary,
              ),
            ),
          ),
          // Bottom left text skeleton
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 18,
              width: 120,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Bottom right text skeleton
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 16,
              width: 72,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
