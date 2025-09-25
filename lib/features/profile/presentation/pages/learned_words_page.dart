import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import 'package:linguess/features/game/data/models/word_model.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';
import 'package:linguess/features/game/data/repositories/word_repository.dart';

class LearnedWordsPage extends ConsumerWidget {
  const LearnedWordsPage({super.key});

  Future<List<WordModel>> _loadDetails(
    List<String> ids,
    WordRepository repo,
    String sortLang,
  ) async {
    if (ids.isEmpty) return const [];
    final list = await Future.wait(ids.map(repo.fetchWordById));
    final words = list.whereType<WordModel>().toList();
    words.sort((a, b) {
      final ta = (a.termOf(sortLang)).toLowerCase();
      final tb = (b.termOf(sortLang)).toLowerCase();
      return ta.compareTo(tb);
    });
    return words;
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final settings = ref.watch(settingsControllerProvider).value;
    final targetLangCode = settings?.targetLangCode ?? 'en';
    final appLangCode = settings?.appLangCode ?? 'en';

    final idsAsync = ref.watch(learnedWordIdsProvider);
    final repo = ref.watch(wordRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learnedWordsText)),
      body: idsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (ids) {
          if (ids.isEmpty) {
            return Center(child: Text(l10n.noDataToShow));
          }
          return FutureBuilder<List<WordModel>>(
            future: _loadDetails(ids, repo, targetLangCode),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text('${l10n.errorOccurred}: ${snap.error}'),
                );
              }
              final words = snap.data ?? const [];

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: words.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final w = words[i];

                  final targetText = w.termOf(targetLangCode);
                  final appText = w.termOf(appLangCode);

                  final titleText = _cap(targetText);
                  final subtitleText = appText;

                  return ListTile(
                    title: Text(titleText),
                    subtitle: Text(subtitleText),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(titleText),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.translation} (${targetLangCode.toUpperCase()}): $targetText',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.translation} (${appLangCode.toUpperCase()}): $appText',
                              ),
                              const SizedBox(height: 8),
                              Text('${l10n.level}: ${w.level}'),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.category}: ${l10n.categoryTitle(w.category)}',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(l10n.close),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
