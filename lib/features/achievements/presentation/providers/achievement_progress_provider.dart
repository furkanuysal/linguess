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
      if (!(def.hasProgress) || def.progressType == null) {
        return const AsyncData<AchievementProgress?>(null);
      }

      // For static types, we need a target.
      if (def.progressType != AchievementProgressType.categoryLearnedComplete &&
          def.progressTarget == null) {
        return const AsyncData<AchievementProgress?>(null);
      }

      final type = def.progressType!;
      final staticTarget = def.progressTarget ?? 0;

      AsyncValue<int> countAsync;
      AsyncValue<int> targetAsync = AsyncData(staticTarget);

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
        case AchievementProgressType.categoryLearnedComplete:
          if (def.progressParam == null) {
            countAsync = const AsyncData(0);
          } else {
            final progress = ref.watch(
              progressProvider(
                ProgressParams(mode: 'category', id: def.progressParam!),
              ),
            );
            countAsync = progress.whenData((p) => p.learnedCount);
            targetAsync = progress.whenData((p) => p.totalCount);
          }
          break;
        case AchievementProgressType.timeAttackHighscore:
          final stats = ref.watch(userStatsProvider);
          countAsync = stats.whenData((s) => s?.timeAttackHighScore ?? 0);
          break;
      }

      return countAsync
              .whenData((count) {
                return targetAsync.whenData((target) {
                  final current = count.clamp(0, target > 0 ? target : 1);
                  return AchievementProgress(current: current, target: target);
                });
              })
              .asData
              ?.value ??
          const AsyncLoading();
    });
