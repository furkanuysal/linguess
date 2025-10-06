import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/admin/presentation/providers/daily_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdminDailyListPage extends ConsumerWidget {
  const AdminDailyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dailyAsync = ref.watch(dailyListProvider);
    final dfDate = DateFormat('yyyy-MM-dd');
    final dfCreated = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.dailyListText,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: dailyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(child: Text(l10n.noDailyEntries));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final d = items[i];
                    final dateStr = dfDate.format(d.date);
                    final createdStr = d.createdAt != null
                        ? dfCreated.format(d.createdAt!)
                        : '—';
                    final enAsync = ref.watch(wordEnByIdProvider(d.wordId));

                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('$dateStr  (${d.id})'),
                      subtitle: enAsync.when(
                        loading: () => Text('wordId: ${d.wordId} • ...'),
                        error: (_, _) => Text('wordId: ${d.wordId}'),
                        data: (en) => Text(
                          en == null || en.isEmpty
                              ? 'wordId: ${d.wordId}'
                              : 'wordId: ${d.wordId} • "$en"',
                        ),
                      ),
                      trailing: Text(createdStr),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
