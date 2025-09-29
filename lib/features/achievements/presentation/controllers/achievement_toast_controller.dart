import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_daily_solved_count_provider.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_learned_count_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/achievements/data/achievement_defs.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/app/router/app_router.dart';

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

    return null;
  }

  // ---- Progress based achievement checking ----
  Future<void> _checkProgressAchievements({
    int? solvedCount,
    int? learnedCount,
    int? dailySolvedCount,
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

    for (final def in defs) {
      if (!(def.hasProgress) ||
          def.progressType == null ||
          def.progressTarget == null) {
        continue;
      }

      final target = def.progressTarget!;
      final current = switch (def.progressType!) {
        AchievementProgressType.solvedWordsTotal => solved,
        AchievementProgressType.learnedWordsTotal => learned,
        AchievementProgressType.dailySolvedTotal => daily,
      };

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
