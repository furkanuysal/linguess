import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/stats/data/repositories/hint_stats_repository.dart';

final hintStatsRepositoryProvider = Provider<HintStatsRepository>((ref) {
  return HintStatsRepository();
});

final hintStatsStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final repo = ref.watch(hintStatsRepositoryProvider);
  return repo.watchHintUsage();
});

final hintStatsProvider = StreamProvider<Map<String, int>?>((ref) {
  final repo = ref.read(hintStatsRepositoryProvider);
  return repo.watchHintUsage().map((data) {
    if (data == null) return null;
    // type-safe: dynamic → int
    return data.map((key, value) => MapEntry(key, (value as num).toInt()));
  });
});
