import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/leaderboard/data/models/leaderboard_entry.dart';

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((
  ref,
) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getLeaderboard();
});
