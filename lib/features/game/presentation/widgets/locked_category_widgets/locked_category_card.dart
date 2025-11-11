import 'package:flutter/material.dart';
import 'package:linguess/features/game/presentation/widgets/category_card.dart';

class LockedCategoryCard extends StatelessWidget {
  const LockedCategoryCard({
    super.key,
    required this.title,
    required this.iconCodePoint,
    required this.price,
    required this.onBuy,
  });

  final String title;
  final String? iconCodePoint;
  final int price;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = 220.0;
        final scale = (constraints.maxWidth / baseWidth).clamp(0.9, 1.1);
        final fontScale = 1 - (1 - scale) * 0.4;

        final bgGradient = [scheme.surface, scheme.surfaceContainerHigh];
        final shadowColor = Colors.black.withValues(alpha: 0.08);

        return Material(
          color: Colors.transparent,
          elevation: 3 * scale,
          borderRadius: BorderRadius.circular(18 * scale),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(18 * scale),
            onTap: () {},
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bgGradient,
                ),
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.45),
                  width: 1.4 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 5 * scale,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top part: icon + lock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryIcon(
                          codePointString: iconCodePoint,
                          size: 46 * scale,
                        ),
                        Icon(
                          Icons.lock_rounded,
                          size: 28 * scale,
                          color: scheme.primary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),

                    // Category title
                    Padding(
                      padding: EdgeInsets.only(top: 6 * scale),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18 * fontScale,
                              color: scheme.onSurface,
                            ),
                      ),
                    ),

                    // Price button
                    Padding(
                      padding: EdgeInsets.only(
                        top: 6 * scale,
                        bottom: 4 * scale,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onBuy,
                        icon: Icon(
                          Icons.monetization_on_rounded,
                          size: 20 * scale,
                          color: Colors.black87,
                        ),
                        label: Text(
                          '$price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * fontScale,
                            color: Colors.black87,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 8 * scale,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
