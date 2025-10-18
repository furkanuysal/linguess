import 'package:flutter/material.dart';

class GradientChoiceChip extends StatelessWidget {
  const GradientChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final gradientColors = isSelected
        ? [
            scheme.primary.withValues(alpha: 0.55),
            scheme.primaryContainer.withValues(alpha: 0.9),
          ]
        : [
            scheme.surfaceContainerLow.withValues(alpha: 0.9),
            scheme.surfaceContainerHigh.withValues(alpha: 0.8),
          ];

    final borderColor = isSelected ? scheme.primary : Colors.transparent;
    final textColor = isSelected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final checkColor = isSelected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 18, color: checkColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
