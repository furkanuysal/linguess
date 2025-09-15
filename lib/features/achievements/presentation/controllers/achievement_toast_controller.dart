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
  @override
  AchievementModel? build() {
    // Listen for changes in the set of earned achievement IDs
    ref.listen<AsyncValue<Set<String>>>(earnedAchievementIdsProvider, (
      previous,
      next,
    ) {
      next.whenData((currentEarned) {
        final previousEarned = previous?.value ?? <String>{};
        final newAchievements = currentEarned.difference(previousEarned);
        if (newAchievements.isNotEmpty) {
          _showToastForNewAchievement(newAchievements.first);
        }
      });
    });

    // Listen for changes in the correct answer count
    ref.listen<AsyncValue<int>>(userCorrectCountProvider, (previous, next) {
      next.whenData((correctCount) async {
        await _checkWordCountAchievements(correctCount);
      });
    });

    return null; // initial state
  }

  // Check all count-based achievements
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

  void _showToastForNewAchievement(String achievementId) {
    final context = ref.read(navigatorKeyProvider).currentContext;
    if (context == null) return;

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
      if (ref.mounted && state?.id == achievementId) {
        state = null;
      }
    });
  }

  void hideToast() {
    state = null;
  }
}
