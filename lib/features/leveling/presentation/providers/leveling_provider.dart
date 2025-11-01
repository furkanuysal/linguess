import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/leveling/data/models/leveling_model.dart';
import 'package:linguess/features/leveling/data/repositories/leveling_repository.dart';

final levelingRepositoryProvider = Provider<LevelingRepository>((ref) {
  return LevelingRepository();
});

final levelingProvider = StreamProvider<LevelingModel?>((ref) {
  final repo = ref.read(levelingRepositoryProvider);
  return repo.watchLeveling();
});
