import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/utils/date_utils.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/stats/presentation/providers/user_stats_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final userDataAsync = ref.watch(userDataProvider);
    final learnedIdsAsync = ref.watch(learnedWordIdsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.profile,
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
            child: userDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
              data: (snap) {
                if (snap == null || !snap.exists) {
                  return Center(child: Text(l10n.noDataToShow));
                }
                final data = snap.data() as Map<String, dynamic>;
                final email = (data['email'] ?? '—') as String;
                final gold = (data['gold'] ?? 0).toString();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // User Info Card
                    _GradientCard(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person_outline,
                            color: scheme.onSurface,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text('${l10n.gold}: $gold'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Learned Words
                    _GradientCard(
                      onTap: () => context.push('/learned-words'),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.menu_book_outlined,
                            color: scheme.onSurface,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          l10n.learnedWordsText,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: learnedIdsAsync.when(
                          loading: () => Text(l10n.loadingText),
                          error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                          data: (ids) => Text(
                            '${l10n.totalLearnedWordsText}: ${ids.length}',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Achievements
                    _GradientCard(
                      onTap: () => context.push('/achievements'),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.emoji_events_outlined,
                            color: scheme.onSurface,
                            size: 26,
                          ),
                        ),
                        title: Text(
                          l10n.achievements,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(l10n.viewAll),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User Stats
                    _GradientCard(
                      child: Consumer(
                        builder: (context, ref, _) {
                          final statsAsync = ref.watch(userStatsProvider);
                          final wordRepo = ref.read(wordRepositoryProvider);
                          final appLang =
                              ref
                                  .read(settingsControllerProvider)
                                  .value
                                  ?.appLangCode ??
                              Localizations.localeOf(context).languageCode;

                          return statsAsync.when(
                            loading: () => ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text(l10n.loadingStatistics),
                            ),
                            error: (e, _) => ListTile(
                              title: Text('${l10n.errorLoadingStats}: $e'),
                            ),
                            data: (stats) {
                              if (stats == null) {
                                return ListTile(
                                  title: Text(l10n.noStatsAvailable),
                                );
                              }

                              final dailyCount = stats.dailySolvedCounter ?? 0;
                              final lastSolvedAt = stats.lastSolvedAt != null
                                  ? formatDateTime(stats.lastSolvedAt!)
                                  : '—';

                              return FutureBuilder(
                                future:
                                    (stats.lastSolvedWordId != null &&
                                        stats.lastSolvedWordId!.isNotEmpty)
                                    ? wordRepo.fetchWordById(
                                        stats.lastSolvedWordId!,
                                      )
                                    : Future.value(null),
                                builder: (context, snapshot) {
                                  final word = snapshot.data;
                                  final lastWordName =
                                      word?.termOf(appLang) ?? '—';

                                  return ListTile(
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: scheme.surfaceContainerHighest
                                            .withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.bar_chart_rounded,
                                        color: scheme.onSurface,
                                        size: 26,
                                      ),
                                    ),
                                    title: Text(
                                      l10n.statistictsTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.dailySolvedCount(dailyCount)),
                                        Text(l10n.lastSolvedWord(lastWordName)),
                                        Text(l10n.lastSolvedAt(lastSolvedAt)),
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

                    const SizedBox(height: 24),

                    // Sign Out
                    SizedBox(
                      height: 52,
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          await ref.read(authServiceProvider).signOut();
                          if (context.mounted) context.go('/');
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(l10n.signOut),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient Card Widget
class _GradientCard extends StatelessWidget {
  const _GradientCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.surface, scheme.surfaceContainerHigh],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}
