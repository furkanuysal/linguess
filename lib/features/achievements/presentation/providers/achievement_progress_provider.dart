import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/data/models/achievement_progress.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_learned_count_provider.dart';
import 'package:linguess/features/achievements/presentation/providers/ach_user_daily_solved_count_provider.dart';

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
      }

      return countAsync.whenData((count) {
        final current = count.clamp(0, target);
        return AchievementProgress(current: current, target: target);
      });
    });
