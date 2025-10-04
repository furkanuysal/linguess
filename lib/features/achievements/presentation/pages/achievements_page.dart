import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievement_progress_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(achievementsViewProvider(context));
    final l10n = AppLocalizations.of(context)!;

    final earnedItems = items.where((e) => e.earned).toList();
    final notEarnedItems = items.where((e) => !e.earned).toList();
    final sortedItems = [...earnedItems, ...notEarnedItems];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.achievements,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: sortedItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 5),
              itemBuilder: (context, i) {
                final item = sortedItems[i];
                final def = item.def;

                final progressAsync = (def.hasProgress && !item.earned)
                    ? ref.watch(achievementProgressProvider(def))
                    : const AsyncData<Null>(null);

                return _AchievementTile(
                  def: def,
                  earned: item.earned,
                  progressAsync: progressAsync,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.def,
    required this.earned,
    required this.progressAsync,
  });

  final AchievementModel def;
  final bool earned;
  final AsyncValue<dynamic> progressAsync; // null or AchievementProgress

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Card style
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.surface, scheme.surfaceContainerHigh],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.emoji_events,
            color: earned ? scheme.primary : scheme.onSurface,
            size: 26,
          ),
        ),
        title: Text(
          def.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: _buildSubtitle(theme, l10n),
        trailing: earned
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Icon(
                Icons.check_circle_outline,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, AppLocalizations l10n) {
    final scheme = theme.colorScheme;

    // Default: just description
    Widget subtitle = Text(def.description);

    // Loading
    if (!earned && progressAsync is AsyncLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.description),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: null,
              minHeight: 8,
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      );
    }

    // Error
    if (!earned && progressAsync is AsyncError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.description),
          const SizedBox(height: 6),
          Text(
            l10n.errorLoadingProgress,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      );
    }

    // Value
    if (!earned && progressAsync.hasValue) {
      final value = progressAsync.value; // null or AchievementProgress
      if (value != null) {
        final current = value.current as int;
        final target = value.target as int;
        final percent = value.percent as int;
        final ratio = (value.ratio as double).clamp(0, 1);

        subtitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.description),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio as double,
                minHeight: 8,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('$current / $target', style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  '$percent%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }

    return subtitle;
  }
}
