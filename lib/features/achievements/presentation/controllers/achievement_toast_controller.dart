import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/achievements/data/achievement_defs.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/app/router/app_router.dart';

final achievementToastProvider =
    StateNotifierProvider<AchievementToastController, AchievementModel?>((ref) {
      return AchievementToastController(ref);
    });

class AchievementToastController extends StateNotifier<AchievementModel?> {
  final Ref ref;

  AchievementToastController(this.ref) : super(null) {
    // Listen to achievements and detect newly earned ones
    ref.listen<AsyncValue<Set<String>>>(earnedAchievementIdsProvider, (
      previous,
      next,
    ) {
      next.whenData((currentEarned) {
        if (previous?.hasValue == true) {
          final previousEarned = previous!.value!;
          final newAchievements = currentEarned.difference(previousEarned);

          if (newAchievements.isNotEmpty) {
            _showToastForNewAchievement(newAchievements.first);
          }
        }
      });
    });

    // Listen to changes in CorrectCount and check for achievements
    ref.listen<AsyncValue<int>>(userCorrectCountProvider, (previous, next) {
      next.whenData((correctCount) async {
        await _checkWordCountAchievements(correctCount);
      });
    });
  }

  // Check all word count based achievements
  Future<void> _checkWordCountAchievements(int correctCount) async {
    final achievementService = ref.read(achievementsServiceProvider);

    // All count-based achievements are checked here
    final wordCountAchievements = {
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
    if (context != null) {
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
        if (mounted && state?.id == achievementId) {
          state = null;
        }
      });
    }
  }

  void hideToast() {
    state = null;
  }
}
