import 'package:flutter/material.dart';

class ProgressBadge extends StatelessWidget {
  const ProgressBadge({super.key, required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 5,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            '${(percent * 100).round()}%',
            style: style?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
