import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/achievements/presentation/providers/achievement_progress_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:linguess/features/achievements/presentation/widgets/achievements_widgets.dart';

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

                      return AchievementTile(
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
