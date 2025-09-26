import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/game/presentation/widgets/card_skeleton.dart';
import 'package:linguess/features/game/presentation/widgets/progress_badge.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (categories) {
          // Invalidate relevant progress providers when categories are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final category in categories) {
              ref.invalidate(
                progressProvider(
                  ProgressParams(mode: 'category', id: category.id),
                ),
              );
            }
          });

          if (categories.isEmpty) {
            // Use ListView + physics to allow pull-to-refresh even when empty
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(categoriesProvider);
                await ref.read(categoriesProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.noDataToShow),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesProvider);
              await ref.read(categoriesProvider.future);
            },
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryCard(
                  id: category.id,
                  titleBuilder: (id) => l10n.categoryTitle(id),
                  iconCodePoint: category.icon, // Material icon code point
                  onTap: () async {
                    await context.push(
                      '/game/category/${category.id}',
                      extra: WordGameParams(
                        mode: 'category',
                        selectedValue: category.id,
                      ),
                    );
                    ref.invalidate(
                      progressProvider(
                        ProgressParams(mode: 'category', id: category.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({
    required this.id,
    required this.titleBuilder,
    required this.onTap,
    this.iconCodePoint,
  });

  final String id;
  final String Function(String id) titleBuilder;
  final String? iconCodePoint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(
      progressProvider(ProgressParams(mode: 'category', id: id)),
    );

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: progressAsync.when(
            loading: () => CardSkeleton(title: titleBuilder(id)),
            error: (_, _) => CardSkeleton(title: titleBuilder(id)),
            data: (p) {
              final learned = p.hasUser ? p.learnedCount : 0;
              final total = math.max(p.totalCount, 1);
              final percent = (learned / total).clamp(0.0, 1.0);

              return Stack(
                children: [
                  // top left: icon
                  Align(
                    alignment: Alignment.topLeft,
                    child: _CategoryIcon(codePointString: iconCodePoint),
                  ),

                  // top right: percentage
                  Align(
                    alignment: Alignment.topRight,
                    child: ProgressBadge(percent: percent),
                  ),

                  // bottom left: title
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        titleBuilder(id),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  // bottom right: learned/total
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      p.hasUser
                          ? '${p.learnedCount}/${p.totalCount}'
                          : '${p.totalCount}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.labelLarge?.color?.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({this.codePointString});
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
