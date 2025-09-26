import 'package:flutter/material.dart';

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surface.withValues(alpha: 0.35);
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 5),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            height: 18,
            width: 120,
            margin: const EdgeInsets.only(bottom: 4),
            color: base,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(height: 16, width: 72, color: base),
        ),
      ],
    );
  }
}
