import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/game/presentation/providers/word_game_provider.dart';
import 'package:linguess/features/game/presentation/widgets/card_skeleton.dart';
import 'package:linguess/features/game/presentation/widgets/progress_badge.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelPage extends ConsumerStatefulWidget {
  const LevelPage({super.key});

  @override
  ConsumerState<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends ConsumerState<LevelPage> {
  bool isGridView = true;
  static const _prefKey = 'isGridView_levelPage';
  bool _isPrefLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? true;
    setState(() {
      isGridView = saved;
      _isPrefLoaded = true;
    });
  }

  Future<void> _saveViewPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final levelsAsync = ref.watch(levelsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        title: l10n.appTitle,
        actions: [
          if (_isPrefLoaded)
            IconButton(
              tooltip: isGridView ? l10n.listViewTooltip : l10n.gridViewTooltip,
              icon: Icon(
                isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: scheme.primary,
              ),
              onPressed: () {
                setState(() => isGridView = !isGridView);
                _saveViewPreference(isGridView);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GradientBackground()),
          SafeArea(
            child: !_isPrefLoaded
                ? const Center(child: CircularProgressIndicator())
                : levelsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('${l10n.errorOccurred}: $e')),
                    data: (levels) {
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.97,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: isGridView
                              ? _buildGrid(levels)
                              : _buildList(levels),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List levels) {
    return GridView.builder(
      key: const ValueKey('gridView'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
            await context.push('/game/level/${level.id}');
            ref.invalidate(
              progressProvider(ProgressParams(mode: 'level', id: level.id)),
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
    );
  }

  Widget _buildList(List levels) {
    return ListView.builder(
      key: const ValueKey('listView'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return _LevelListTile(
          id: level.id,
          title: level.id,
          onTap: () async {
            await context.push('/game/level/${level.id}');
            ref.invalidate(
              progressProvider(ProgressParams(mode: 'level', id: level.id)),
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

class _LevelListTile extends ConsumerWidget {
  const _LevelListTile({
    required this.id,
    required this.title,
    required this.onTap,
  });

  final String id;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final progressAsync = ref.watch(
      progressProvider(ProgressParams(mode: 'level', id: id)),
    );

    final gradientColors = [
      scheme.surfaceContainerLow.withValues(alpha: 0.9),
      scheme.surfaceContainerHigh.withValues(alpha: 0.8),
    ];

    final borderColor = Colors.transparent;
    final shadowColor = Colors.black.withValues(alpha: 0.05);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        elevation: 1.5,
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
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: progressAsync.when(
              loading: () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const CircularProgressIndicator(strokeWidth: 2),
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
                    // Left: title and progress bar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
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
                                    color: scheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right: learned/total + percentage
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
