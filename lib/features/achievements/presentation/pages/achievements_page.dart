import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievements)),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = items[i];
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
  final AsyncValue<dynamic>
  progressAsync; // dynamic because null or AchievementProgress

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Leading icon
    final leadingIcon = Icon(
      Icons.emoji_events,
      color: earned ? theme.colorScheme.primary : null,
    );

    // Trailing: If earned, show a check icon — else a hollow check icon
    final trailing = earned
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.check_circle_outline);

    // Subtitle: description + (if hasProgress and not earned: progress bar)
    Widget subtitle = Text(def.description);

    if (!earned && progressAsync.hasValue) {
      final value = progressAsync.value; // null or AchievementProgress
      if (value != null) {
        final current = value.current as int;
        final target = value.target as int;
        final percent = value.percent as int;
        final ratio = value.ratio as double;

        subtitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.description),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio.clamp(0, 1),
                minHeight: 8,
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
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }

    // Loading / error states (for progress)
    if (!earned && progressAsync is AsyncLoading) {
      subtitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.description),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: null, // indeterminate
              minHeight: 8,
            ),
          ),
        ],
      );
    } else if (!earned && progressAsync is AsyncError) {
      subtitle = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.description),
          const SizedBox(height: 6),
          Text(
            l10n.errorLoadingProgress,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      );
    }

    return ListTile(
      leading: leadingIcon,
      title: Text(def.title),
      subtitle: subtitle,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}
