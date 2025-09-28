import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/data/achievement_defs.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/achievements/data/services/achievement_service.dart';

final achievementsServiceProvider = Provider<AchievementsService>((ref) {
  return AchievementsService();
});

// Watches the set of achievement IDs earned by the user as a stream
final earnedAchievementIdsProvider = StreamProvider<Set<String>>((ref) {
  final svc = ref.watch(achievementsServiceProvider);
  return svc.earnedIdsStream();
});

// Watches the set of achievement IDs not yet notified to the user as a stream
final unnotifiedAchievementIdsProvider = StreamProvider<Set<String>>((ref) {
  final svc = ref.watch(achievementsServiceProvider);
  return svc.unnotifiedIdsStream();
});

// For UI: definitions + earned status
final achievementsViewProvider = Provider.autoDispose
    .family<List<({AchievementModel def, bool earned})>, BuildContext>((
      ref,
      context,
    ) {
      final earned =
          ref.watch(earnedAchievementIdsProvider).value ?? <String>{};
      final defs = buildAchievements(context);

      return defs.map((d) => (def: d, earned: earned.contains(d.id))).toList();
    });
