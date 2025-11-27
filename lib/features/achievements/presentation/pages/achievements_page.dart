import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievement_progress_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';

enum AchievementFilter { all, earned, unearned }

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  AchievementFilter _filter = AchievementFilter.all;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(achievementsViewProvider(context));
    final l10n = AppLocalizations.of(context)!;
    final shopItemsAsync = ref.watch(shopItemsProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Filtering
    final filteredItems = items.where((e) {
      switch (_filter) {
        case AchievementFilter.all:
          return true;
        case AchievementFilter.earned:
          return e.earned;
        case AchievementFilter.unearned:
          return !e.earned;
      }
    }).toList();

    // Sorting
    final earnedItems = filteredItems.where((e) => e.earned).toList();
    final notEarnedItems = filteredItems.where((e) => !e.earned).toList();

    // Sort unearned items by progress (descending)
    final unearnedWithProgress = notEarnedItems.map((item) {
      final progressAsync = item.def.hasProgress
          ? ref.watch(achievementProgressProvider(item.def))
          : const AsyncData(null);

      double ratio = 0.0;
      if (progressAsync.hasValue && progressAsync.value != null) {
        final val = progressAsync.value;
        if (val != null) {
          ratio = val.ratio.clamp(0.0, 1.0);
        }
      }
      return (item: item, ratio: ratio);
    }).toList();

    unearnedWithProgress.sort((a, b) => b.ratio.compareTo(a.ratio));
    final sortedUnearned = unearnedWithProgress.map((e) => e.item).toList();

    final sortedItems = [...sortedUnearned, ...earnedItems];

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
            child: Column(
              children: [
                Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: SegmentedButton<AchievementFilter>(
                        segments: [
                          ButtonSegment(
                            value: AchievementFilter.all,
                            label: Text(l10n.allText),
                          ),
                          ButtonSegment(
                            value: AchievementFilter.earned,
                            label: Text(l10n.filterEarned),
                          ),
                          ButtonSegment(
                            value: AchievementFilter.unearned,
                            label: Text(l10n.filterUnearned),
                          ),
                        ],
                        selected: {_filter},
                        onSelectionChanged:
                            (Set<AchievementFilter> newSelection) {
                              setState(() {
                                _filter = newSelection.first;
                              });
                            },
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return scheme.primary;
                                }
                                return null;
                              }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return scheme.onPrimary;
                                }
                                return scheme.onSurface;
                              }),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),
                Expanded(
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
                            shopItemsAsync: shopItemsAsync,
                          )
                          .animate(delay: (50 * i).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0);
                    },
                  ),
                ),
              ],
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
    required this.shopItemsAsync,
  });

  final AchievementModel def;
  final bool earned;
  final AsyncValue<dynamic> progressAsync; // null or AchievementProgress
  final AsyncValue<List<dynamic>> shopItemsAsync;

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
            border: earned
                ? Border.all(
                    color: scheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubtitle(theme, l10n),
            if (def.reward != null) ...[
              const SizedBox(height: 8),
              _buildReward(context, theme, l10n),
            ],
          ],
        ),
        trailing: earned
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Icon(
                Icons.check_circle_outline,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
      ),
    );
  }

  Widget _buildReward(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final reward = def.reward!;
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                reward is GoldReward
                    ? Icons.monetization_on
                    : Icons.inventory_2,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              if (reward is GoldReward)
                Text(
                  '${reward.amount} ${l10n.gold}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (reward is ItemReward)
                Builder(
                  builder: (context) {
                    final itemId = reward.itemId;
                    final itemName = shopItemsAsync.maybeWhen(
                      data: (items) {
                        final item = items.firstWhere(
                          (i) => i.id == itemId,
                          orElse: () => ShopItem(
                            id: itemId,
                            type: ShopItemType.other,
                            price: 0,
                            requiredLevel: 0,
                            rarity: 'common',
                            iconUrl: '',
                            translations: {},
                          ),
                        );
                        return item.nameFor(l10n.localeName);
                      },
                      orElse: () => l10n.loadingText,
                    );

                    return Text(
                      itemName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
            ],
          ),
          if (earned)
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
            ),
        ],
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
