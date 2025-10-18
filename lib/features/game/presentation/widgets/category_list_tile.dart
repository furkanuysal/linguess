import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class CategoryListTile extends ConsumerWidget {
  const CategoryListTile({
    super.key,
    required this.id,
    required this.title,
    required this.onTap,
    this.iconCodePoint,
    this.isSelected = false,
  });

  final String id;
  final String title;
  final String? iconCodePoint;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(
      progressProvider(ProgressParams(mode: 'category', id: id)),
    );

    IconData? iconData;
    if (iconCodePoint != null) {
      try {
        iconData = IconData(
          int.parse(iconCodePoint!),
          fontFamily: 'MaterialIcons',
        );
      } catch (_) {}
    }

    // Gradient colors
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
    final shadowColor = isSelected
        ? scheme.primary.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        elevation: isSelected ? 4 : 1.5,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: progressAsync.when(
              loading: () => Row(
                children: [
                  _CategoryIcon(iconData: iconData),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (p) {
                final learned = p.hasUser ? p.learnedCount : 0;
                final total = math.max(p.totalCount, 1);
                final percent = (learned / total).clamp(0.0, 1.0);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CategoryIcon(iconData: iconData),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                          const SizedBox(height: 5),
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percent,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? scheme.onPrimaryContainer
                                        : scheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.hasUser
                              ? '${p.learnedCount}/${p.totalCount}'
                              : '${p.totalCount} ${l10n.totalWordText}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '${(percent * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
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

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconData});
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData ?? Icons.category_outlined,
        color: scheme.primary,
        size: 26,
      ),
    );
  }
}
