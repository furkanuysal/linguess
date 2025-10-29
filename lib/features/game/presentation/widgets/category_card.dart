import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/game/presentation/widgets/progress_badge.dart';
import 'package:linguess/features/game/presentation/widgets/card_skeleton.dart';

class CategoryCard extends ConsumerWidget {
  const CategoryCard({
    super.key,
    required this.id,
    required this.title,
    required this.onTap,
    this.iconCodePoint,
    this.isSelected = false,
    this.showProgress = true,
  });

  final String id;
  final String title;
  final String? iconCodePoint;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = 220.0;
        final scale = (constraints.maxWidth / baseWidth).clamp(0.95, 1.08);
        final fontScale = 1 - (1 - scale) * 0.4;

        final scheme = Theme.of(context).colorScheme;
        final progressAsync = ref.watch(
          progressProvider(ProgressParams(mode: 'category', id: id)),
        );

        final bgGradient = isSelected
            ? [scheme.primary.withValues(alpha: 0.6), scheme.primaryContainer]
            : [scheme.surface, scheme.surfaceContainerHigh];

        final borderColor = isSelected ? scheme.primary : Colors.transparent;
        final shadowColor = isSelected
            ? scheme.primary.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.05);

        return Material(
          color: Colors.transparent,
          elevation: 3 * scale,
          borderRadius: BorderRadius.circular(18 * scale),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18 * scale),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bgGradient,
                ),
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(color: borderColor, width: 2 * scale),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: isSelected ? 8 * scale : 5 * scale,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 8 * scale,
                ),
                child: progressAsync.when(
                  loading: () => CardSkeleton(title: title),
                  error: (_, _) => CardSkeleton(title: title),
                  data: (p) {
                    final learned = p.hasUser ? p.learnedCount : 0;
                    final total = math.max(p.totalCount, 1);
                    final percent = (learned / total).clamp(0.0, 1.0);

                    return Stack(
                      children: [
                        // Left top icon
                        Positioned(
                          left: 10 * scale,
                          top: 10 * scale,
                          child: Transform.scale(
                            scale: scale,
                            child: CategoryIcon(
                              codePointString: iconCodePoint,
                              size: 44 * scale,
                            ),
                          ),
                        ),

                        // Right top progress badge
                        if (showProgress)
                          Positioned(
                            right: 10 * scale,
                            top: 10 * scale,
                            child: Transform.scale(
                              scale: scale,
                              child: ProgressBadge(percent: percent),
                            ),
                          ),

                        // Bottom aligned texts (left-bottom + right-bottom)
                        Positioned(
                          left: 10 * scale,
                          right: 10 * scale,
                          bottom: 8 * scale,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              // Left bottom category name
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 6 * scale),
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18 * fontScale,
                                          height: 1.0,
                                          color: isSelected
                                              ? scheme.onPrimaryContainer
                                              : scheme.onSurface,
                                        ),
                                  ),
                                ),
                              ),

                              // Right bottom progress count
                              if (showProgress)
                                Text(
                                  p.hasUser
                                      ? '${p.learnedCount}/${p.totalCount}'
                                      : '${p.totalCount}',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontSize: 16 * fontScale,
                                        height: 1.0,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.color
                                            ?.withValues(alpha: 0.85),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, this.codePointString, this.size = 44});

  final String? codePointString;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
    final fg = Theme.of(context).colorScheme.primary;

    IconData? data;
    if (codePointString != null) {
      try {
        data = IconData(
          int.parse(codePointString!),
          fontFamily: 'MaterialIcons',
        );
      } catch (_) {}
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(
        data ?? Icons.category_outlined,
        color: fg,
        size: size * 0.65,
      ),
    );
  }
}
