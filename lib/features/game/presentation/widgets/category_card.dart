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
      elevation: 3,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgGradient,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isSelected ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: progressAsync.when(
              loading: () => CardSkeleton(title: title),
              error: (_, _) => CardSkeleton(title: title),
              data: (p) {
                final learned = p.hasUser ? p.learnedCount : 0;
                final total = math.max(p.totalCount, 1);
                final percent = (learned / total).clamp(0.0, 1.0);

                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: CategoryIcon(codePointString: iconCodePoint),
                    ),
                    if (showProgress)
                      Align(
                        alignment: Alignment.topRight,
                        child: ProgressBadge(percent: percent),
                      ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurface,
                              ),
                        ),
                      ),
                    ),
                    if (showProgress)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          p.hasUser
                              ? '${p.learnedCount}/${p.totalCount}'
                              : '${p.totalCount}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.color
                                    ?.withValues(alpha: 0.75),
                              ),
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
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, this.codePointString});
  final String? codePointString;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);
    final fg = Theme.of(context).colorScheme.onPrimaryContainer;

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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(data ?? Icons.category_outlined, color: fg, size: 26),
    );
  }
}
