import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import 'package:linguess/models/word_model.dart';
import 'package:linguess/providers/word_repository_provider.dart';
import 'package:linguess/repositories/word_repository.dart';

class LearnedWordsPage extends ConsumerWidget {
  const LearnedWordsPage({super.key});

  Future<List<WordModel>> _loadDetails(
    List<String> ids,
    WordRepository repo,
  ) async {
    if (ids.isEmpty) return const [];
    final list = await Future.wait(ids.map(repo.fetchWordById));
    return list.whereType<WordModel>().toList()..sort((a, b) {
      final ea = (a.translations['en'] ?? '').toLowerCase();
      final eb = (b.translations['en'] ?? '').toLowerCase();
      return ea.compareTo(eb);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final idsAsync = ref.watch(learnedWordIdsProvider);
    final repo = ref.watch(wordRepositoryProvider);
    final locale = Localizations.localeOf(context).languageCode;

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
            future: _loadDetails(ids, repo),
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
                  final en = (w.translations['en'] ?? '???');
                  final enCap = en.isEmpty
                      ? en
                      : en[0].toUpperCase() + en.substring(1).toLowerCase();
                  final local = w.translations[locale] ?? '???';

                  return ListTile(
                    title: Text(enCap),
                    subtitle: Text(local),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(enCap),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l10n.translation}: $local'),
                              const SizedBox(height: 4),
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
