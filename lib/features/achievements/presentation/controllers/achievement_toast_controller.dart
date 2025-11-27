import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_daily_solved_count_provider.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_learned_count_provider.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/stats/data/models/user_stats_model.dart';
import 'package:linguess/features/stats/presentation/providers/user_stats_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/achievements/data/achievement_defs.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/app/router/app_router.dart';
import 'package:linguess/features/shop/utils/shop_refresh.dart';

final achievementToastProvider =
    NotifierProvider<AchievementToastController, AchievementModel?>(
      AchievementToastController.new,
    );

class AchievementToastController extends Notifier<AchievementModel?> {
  // ---- toast queue ----
  final List<String> _queue = [];
  bool _showing = false;

  @override
  AchievementModel? build() {
    // Listen to earned achievement IDs
    ref.listen<AsyncValue<Set<String>>>(unnotifiedAchievementIdsProvider, (
      prev,
      next,
    ) {
      final previous = prev?.value ?? <String>{};
      next.whenData((current) {
        final newlyAdded = current.difference(previous);
        for (final id in newlyAdded) {
          _enqueueToast(id);
        }
      });
    });
    // solved words achievements
    ref.listen<AsyncValue<int>>(userCorrectCountProvider, (_, next) {
      next.whenData((solved) async {
        await _checkProgressAchievements(solvedCount: solved);
      });
    });

    // learned words achievements
    ref.listen<AsyncValue<int>>(achUserLearnedCountProvider, (_, next) {
      next.whenData((learned) async {
        await _checkProgressAchievements(learnedCount: learned);
      });
    });

    // daily solved achievements
    ref.listen<AsyncValue<int>>(achUserDailySolvedCountProvider, (_, next) {
      next.whenData((daily) async {
        await _checkProgressAchievements(dailySolvedCount: daily);
      });
    });

    // time attack achievements
    ref.listen<AsyncValue<UserStatsModel?>>(userStatsProvider, (_, next) {
      next.whenData((stats) async {
        if (stats != null && stats.timeAttackHighScore != null) {
          await _checkProgressAchievements(
            timeAttackHighScore: stats.timeAttackHighScore,
          );
        }
      });
    });

    return null;
  }

  // ---- Progress based achievement checking ----
  Future<void> _checkProgressAchievements({
    int? solvedCount,
    int? learnedCount,
    int? dailySolvedCount,
    int? timeAttackHighScore,
  }) async {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context == null) return;

    final defs = buildAchievements(context);
    final service = ref.read(achievementsServiceProvider);

    // Complete missing values from current provider values
    final solved = solvedCount ?? ref.read(userCorrectCountProvider).value ?? 0;
    final learned =
        learnedCount ?? ref.read(achUserLearnedCountProvider).value ?? 0;
    final daily =
        dailySolvedCount ??
        ref.read(achUserDailySolvedCountProvider).value ??
        0;
    final timeAttack =
        timeAttackHighScore ??
        ref.read(userStatsProvider).value?.timeAttackHighScore ??
        0;

    for (final def in defs) {
      if (!(def.hasProgress) || def.progressType == null) {
        continue;
      }

      // Skip if target is null and NOT a dynamic type
      if (def.progressType != AchievementProgressType.categoryLearnedComplete &&
          def.progressTarget == null) {
        continue;
      }

      int target = def.progressTarget ?? 0;
      int current = 0;

      switch (def.progressType!) {
        case AchievementProgressType.solvedWordsTotal:
          current = solved;
          break;
        case AchievementProgressType.learnedWordsTotal:
          current = learned;
          break;
        case AchievementProgressType.dailySolvedTotal:
          current = daily;
          break;
        case AchievementProgressType.timeAttackHighscore:
          current = timeAttack;
          break;
        case AchievementProgressType.categoryLearned:
          if (def.progressParam != null) {
            // Fetch specific category progress
            final progressAsync = await ref.read(
              progressProvider(
                ProgressParams(mode: 'category', id: def.progressParam!),
              ).future,
            );
            current = progressAsync.learnedCount;
          }
          break;
        case AchievementProgressType.categoryLearnedComplete:
          if (def.progressParam != null) {
            final progressAsync = await ref.read(
              progressProvider(
                ProgressParams(mode: 'category', id: def.progressParam!),
              ).future,
            );
            current = progressAsync.learnedCount;
            target = progressAsync.totalCount;
          }
          break;
      }

      if (current >= target) {
        await service.awardIfNotEarned(def.id);
      }
    }
  }

  // ---- Queue management ----
  void _enqueueToast(String achievementId) {
    _queue.add(achievementId);
    if (!_showing) _dequeueAndShowNext();
  }

  void _dequeueAndShowNext() {
    if (_queue.isEmpty || _showing) return;
    _showing = true;

    final nextId = _queue.removeAt(0);
    _showToastForAchievement(nextId);
  }

  void _showToastForAchievement(String achievementId) {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context == null) {
      _showing = false;
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final achievements = buildAchievements(context);

    final achievement = achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => AchievementModel(
        id: achievementId,
        title: l10n.unknownAchievementTitleText,
        description: l10n.unknownAchievementDescriptionText,
        icon: '/empty',
        hasProgress: false,
      ),
    );

    state = achievement;

    // Invalidate providers to refresh UI (gold, inventory)
    invalidateShopProviders(ref);

    Future.delayed(const Duration(seconds: 3), () async {
      if (!ref.mounted) return;
      // Clear the state and show the next toast when closing the current one
      try {
        await ref.read(achievementsServiceProvider).markNotified(achievementId);
      } catch (_) {}
      state = null;
      _showing = false;
      _dequeueAndShowNext();
    });
  }

  // Manually hide the toast
  void hideToast() {
    state = null;
    _showing = false;
    _dequeueAndShowNext();
  }
}
