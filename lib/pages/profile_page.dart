import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import 'package:linguess/models/word_model.dart';
import 'package:linguess/providers/auth_provider.dart';
import 'package:linguess/providers/user_data_provider.dart';
import 'package:linguess/providers/word_repository_provider.dart';
import 'package:linguess/repositories/word_repository.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<List<WordModel>> _fetchLearnedWordsDetails(
    List<String> learnedWordIds,
    WordRepository wordRepository,
  ) {
    return Future.wait(
      learnedWordIds.map((id) => wordRepository.fetchWordById(id)),
    ).then((list) => list.whereType<WordModel>().toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);
    final wordRepository = ref.watch(wordRepositoryProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profile)),
      body: userDataAsync.when(
        data: (snapshot) {
          if (snapshot == null || !snapshot.exists) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noDataToShow),
            );
          }

          final data = snapshot.data() as Map<String, dynamic>;
          final email = data['email'] ?? 'None';
          final gold = data['gold'] ?? 0;
          final learnedWords = List<String>.from(data['learnedWords'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.email}: $email',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  '${AppLocalizations.of(context)!.gold}: $gold',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  '${AppLocalizations.of(context)!.learnedWordsText} (${learnedWords.length}):',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<WordModel>>(
                    future: _fetchLearnedWordsDetails(
                      learnedWords,
                      wordRepository,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            '${AppLocalizations.of(context)!.errorOccurred}: ${snapshot.error}',
                          ),
                        );
                      }
                      final words = snapshot.data ?? [];

                      return ListView.builder(
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          final word = words[index];
                          final enText = word.translations['en'] ?? '???';
                          final localText = word.translations[locale] ?? '???';

                          return ListTile(
                            title: Text(
                              enText[0].toUpperCase() +
                                  enText.substring(1).toLowerCase(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(enText),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context)!.translation}: $localText',
                                      ),
                                      Text(
                                        '${AppLocalizations.of(context)!.level}: ${word.level}',
                                      ),
                                      Text(
                                        '${AppLocalizations.of(context)!.category}: ${AppLocalizations.of(context)!.categoryTitle(word.category)}',
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: Text(
                                        AppLocalizations.of(context)!.close,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      context.go('/'); // Redirect to home after logout
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.logout),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
        ),
      ),
    );
  }
}
