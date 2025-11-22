import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/core/presentation/widgets/gradient_card.dart';
import 'package:linguess/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final currentUserUid = currentUser()?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.leaderboardTitle,
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
            child: leaderboardAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noDataToShow,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final rank = index + 1;
                    final isCurrentUser = entry.uid == currentUserUid;

                    return GradientCard(
                      border: isCurrentUser
                          ? Border.all(color: scheme.primary, width: 2)
                          : null,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: _rankBox(scheme, rank),
                        title: Text(
                          entry.formattedName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.correctCount}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('${l10n.errorOccurred}: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankBox(ColorScheme scheme, int rank) {
    Color backgroundColor;
    Color textColor;

    switch (rank) {
      case 1:
        backgroundColor = const Color(0xFFFFD700); // Gold
        textColor = Colors.black87;
        break;
      case 2:
        backgroundColor = const Color(0xFFC0C0C0); // Silver
        textColor = Colors.black87;
        break;
      case 3:
        backgroundColor = const Color(0xFFCD7F32); // Bronze
        textColor = Colors.black87;
        break;
      default:
        backgroundColor = scheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        );
        textColor = scheme.onSurface;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
