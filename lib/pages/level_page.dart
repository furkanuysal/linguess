import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/game/word_game_state.dart';
import 'package:linguess/providers/learned_count_provider.dart';
import 'package:linguess/providers/word_game_provider.dart';
import 'package:linguess/models/level_model.dart';
import 'package:linguess/providers/level_repository_provider.dart';
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
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: levelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (levels) {
          // Invalidate relevant progress providers when levels are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final level in levels) {
              ref.invalidate(
                progressProvider(ProgressParams(mode: 'level', id: level.id)),
              );
            }
          });

          if (levels.isEmpty) {
            return Center(child: Text(l10n.noDataToShow));
          }

          return ListView.builder(
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final LevelModel level = levels[index];

              return ListTile(
                title: Text(level.id),
                subtitle: ref
                    .watch(
                      progressProvider(
                        ProgressParams(mode: 'level', id: level.id),
                      ),
                    )
                    .when(
                      data: (p) => Text(
                        p.hasUser
                            ? '${p.learnedCount}/${p.totalCount} ${l10n.learnedCountText}'
                            : '${p.totalCount} ${l10n.totalWordText}',
                      ),
                      loading: () => const Text('...'),
                      error: (_, _) => const Text('-'),
                    ),
                onTap: () {
                  context
                      .push(
                        '/game/level/${level.id}',
                        extra: WordGameParams(
                          mode: 'level',
                          selectedValue: level.id,
                        ),
                      )
                      .then((_) {
                        // Refresh relevant providers on return
                        ref.invalidate(
                          progressProvider(
                            ProgressParams(mode: 'level', id: level.id),
                          ),
                        );
                        ref.invalidate(
                          wordGameProvider(
                            WordGameParams(
                              mode: 'level',
                              selectedValue: level.id,
                            ),
                          ),
                        );
                      });
                },
              );
            },
          );
        },
      ),
    );
  }
}
