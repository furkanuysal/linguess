import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userDataAsync = ref.watch(userDataProvider);
    final learnedIdsAsync = ref.watch(learnedWordIdsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: userDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (snap) {
          if (snap == null || !snap.exists) {
            return Center(child: Text(l10n.noDataToShow));
          }
          final data = snap.data() as Map<String, dynamic>;
          final email = data['email'] ?? '—';
          final gold = (data['gold'] ?? 0).toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Card(
                child: ListTile(
                  title: Text(email, style: const TextStyle(fontSize: 18)),
                  subtitle: Text('${l10n.gold}: $gold'),
                  leading: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),

              // Go to learned words page
              Card(
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.learnedWordsText),
                  subtitle: learnedIdsAsync.when(
                    loading: () => Text(l10n.loadingText),
                    error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                    data: (ids) =>
                        Text('${l10n.totalLearnedWordsText}: ${ids.length}'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/learned-words'),
                ),
              ),
              const SizedBox(height: 8),

              // Go to achievements page
              Card(
                child: ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: Text(l10n.achievements),
                  subtitle: Text(l10n.viewAll),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/achievements'),
                ),
              ),
              const SizedBox(height: 24),

              // Log out
              FilledButton.tonalIcon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) context.go('/');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.signOut),
              ),
            ],
          );
        },
      ),
    );
  }
}
