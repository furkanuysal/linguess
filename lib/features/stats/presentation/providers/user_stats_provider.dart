import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/stats/data/models/user_stats_model.dart';
import 'package:linguess/features/stats/data/repositories/global_stats_repository.dart';

// Repository provider (singleton)
final statsRepositoryProvider = Provider<GlobalStatsRepository>((ref) {
  return GlobalStatsRepository();
});

// Watch user statistics as a stream
final userStatsProvider = StreamProvider<UserStatsModel?>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  final user = userAsync.value;

  if (user == null) {
    return Stream.value(null);
  }

  final repo = ref.watch(statsRepositoryProvider);
  return repo.watchUserStats();
});
