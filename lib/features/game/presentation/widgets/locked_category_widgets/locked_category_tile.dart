import 'package:flutter/material.dart';

class LockedCategoryTile extends StatelessWidget {
  const LockedCategoryTile({
    super.key,
    required this.title,
    required this.price,
    required this.iconCodePoint,
    required this.onBuy,
  });

  final String title;
  final int price;
  final String? iconCodePoint;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    IconData? iconData;
    if (iconCodePoint != null) {
      try {
        iconData = IconData(
          int.parse(iconCodePoint!),
          fontFamily: 'MaterialIcons',
        );
      } catch (_) {}
    }

    final gradientColors = [
      scheme.surfaceContainerLow.withValues(alpha: 0.9),
      scheme.surfaceContainerHigh.withValues(alpha: 0.8),
    ];

    final borderColor = scheme.outlineVariant.withValues(alpha: 0.4);
    final shadowColor = Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        elevation: 1.5,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // Locked, no action on tap
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    iconData ?? Icons.lock_outline_rounded,
                    color: scheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Price button
                ElevatedButton.icon(
                  onPressed: onBuy,
                  icon: const Icon(Icons.monetization_on_rounded, size: 18),
                  label: Text(
                    '$price',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
