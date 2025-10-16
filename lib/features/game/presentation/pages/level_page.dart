import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/game/presentation/providers/word_game_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/game/presentation/widgets/card_skeleton.dart';
import 'package:linguess/features/game/presentation/widgets/progress_badge.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class LevelPage extends ConsumerStatefulWidget {
  const LevelPage({super.key});

  @override
  ConsumerState<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends ConsumerState<LevelPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levelsAsync = ref.watch(levelsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: l10n.appTitle,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: GradientBackground()),
          SafeArea(
            child: levelsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
              data: (levels) {
                // invalidate progress providers
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  for (final level in levels) {
                    ref.invalidate(
                      progressProvider(
                        ProgressParams(mode: 'level', id: level.id),
                      ),
                    );
                  }
                });

                if (levels.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(levelsProvider);
                      await ref.read(levelsProvider.future);
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
                    ref.invalidate(levelsProvider);
                    await ref.read(levelsProvider.future);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.15,
                        ),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      return _LevelCard(
                        id: level.id,
                        titleBuilder: (id) => id,
                        onTap: () async {
                          await context.push(
                            '/game/level/${level.id}',
                            extra: WordGameParams(
                              modes: {GameModeType.level},
                              filters: {'level': level.id},
                            ),
                          );
                          // invalidate providers
                          ref.invalidate(
                            progressProvider(
                              ProgressParams(mode: 'level', id: level.id),
                            ),
                          );
                          ref.invalidate(
                            wordGameProvider(
                              WordGameParams(
                                modes: {GameModeType.level},
                                filters: {'level': level.id},
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends ConsumerWidget {
  const _LevelCard({
    required this.id,
    required this.titleBuilder,
    required this.onTap,
  });

  final String id;
  final String Function(String id) titleBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final progressAsync = ref.watch(
      progressProvider(ProgressParams(mode: 'level', id: id)),
    );

    return Material(
      elevation: 2,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.surface, scheme.surfaceContainerHigh],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
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
                    // top left: title
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          titleBuilder(id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                        ),
                      ),
                    ),
                    // top right: percentage
                    Align(
                      alignment: Alignment.topRight,
                      child: ProgressBadge(percent: percent),
                    ),
                    // bottom right: learned/total
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        p.hasUser
                            ? '${p.learnedCount}/${p.totalCount} ${l10n.learnedCountText}'
                            : '${p.totalCount} ${l10n.totalWordText}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).textTheme.labelLarge?.color
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
