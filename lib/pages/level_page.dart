import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/game/word_game_state.dart';
import 'package:linguess/providers/learned_count_provider.dart';
import 'package:linguess/providers/word_game_provider.dart';
import 'package:linguess/models/level_model.dart';
import 'package:linguess/repositories/level_repository.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class LevelPage extends ConsumerStatefulWidget {
  const LevelPage({super.key});

  @override
  ConsumerState<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends ConsumerState<LevelPage> {
  final LevelRepository _levelRepository = LevelRepository();
  List<LevelModel> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _levels = await _levelRepository.fetchLevels();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final level = _levels[index];
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
                          // Revalidate the provider when returning
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
            ),
    );
  }
}
