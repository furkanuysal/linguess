import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _initialized = false; // Skip the first snapshot

  @override
  AchievementModel? build() {
    // Listen to earned achievement IDs
    ref.listen<AsyncValue<Set<String>>>(earnedAchievementIdsProvider, (
      previous,
      next,
    ) {
      // Skip the first emission (existing documents at startup)
      if (!_initialized) {
        _initialized = true;
        return;
      }

      final prev = previous?.value ?? <String>{};
      next.whenData((curr) {
        final newlyAdded = curr.difference(prev);
        if (newlyAdded.isNotEmpty) {
          for (final id in newlyAdded) {
            _enqueueToast(id);
          }
        }
      });
    });

    // Listen to the correct count (may trigger awardIfNotEarned)
    ref.listen<AsyncValue<int>>(userCorrectCountProvider, (previous, next) {
      next.whenData((correctCount) async {
        await _checkWordCountAchievements(correctCount);
      });
    });

    return null;
  }

  // Count-based achievements
  Future<void> _checkWordCountAchievements(int correctCount) async {
    final achievementService = ref.read(achievementsServiceProvider);

    final wordCountAchievements = {
      1: 'solve_firstword',
      10: 'solve_ten_words',
      50: 'solve_fifty_words',
      100: 'solve_hundred_words',
      500: 'solve_fivehundred_words',
      1000: 'solve_thousand_words',
    };

    for (final entry in wordCountAchievements.entries) {
      if (correctCount >= entry.key) {
        await achievementService.awardIfNotEarned(entry.value);
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
      ),
    );

    state = achievement;

    Future.delayed(const Duration(seconds: 3), () {
      if (!ref.mounted) return;
      // Clear the state and show the next toast when closing the current one
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
