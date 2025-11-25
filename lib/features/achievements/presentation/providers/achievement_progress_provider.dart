import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/data/models/achievement_progress.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_learned_count_provider.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_daily_solved_count_provider.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/stats/presentation/providers/user_stats_provider.dart';

final achievementProgressProvider =
    Provider.family<AsyncValue<AchievementProgress?>, AchievementModel>((
      ref,
      def,
    ) {
      if (!(def.hasProgress) ||
          def.progressType == null ||
          def.progressTarget == null) {
        return const AsyncData<AchievementProgress?>(null);
      }

      final type = def.progressType!;
      final target = def.progressTarget!;

      AsyncValue<int> countAsync;
      switch (type) {
        case AchievementProgressType.solvedWordsTotal:
          countAsync = ref.watch(userCorrectCountProvider);
          break;
        case AchievementProgressType.learnedWordsTotal:
          countAsync = ref.watch(achUserLearnedCountProvider);
          break;
        case AchievementProgressType.dailySolvedTotal:
          countAsync = ref.watch(achUserDailySolvedCountProvider);
          break;
        case AchievementProgressType.categoryLearned:
          if (def.progressParam == null) {
            countAsync = const AsyncData(0);
          } else {
            final progress = ref.watch(
              progressProvider(
                ProgressParams(mode: 'category', id: def.progressParam!),
              ),
            );
            countAsync = progress.whenData((p) => p.learnedCount);
          }
          break;
        case AchievementProgressType.timeAttackHighscore:
          final stats = ref.watch(userStatsProvider);
          countAsync = stats.whenData((s) => s?.timeAttackHighScore ?? 0);
          break;
      }

      return countAsync.whenData((count) {
        final current = count.clamp(0, target);
        return AchievementProgress(current: current, target: target);
      });
    });
