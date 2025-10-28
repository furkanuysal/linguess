import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/stats/data/models/user_stats_model.dart';
import 'package:linguess/features/stats/data/repositories/global_stats_repository.dart';

// Repository provider (singleton)
final statsRepositoryProvider = Provider<GlobalStatsRepository>((ref) {
  return GlobalStatsRepository();
});

// Watch user statistics as a stream
final userStatsProvider = StreamProvider<UserStatsModel?>((ref) {
  final repo = ref.watch(statsRepositoryProvider);
  return repo.watchUserStats();
});
