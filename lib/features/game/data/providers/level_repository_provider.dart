import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/data/models/level_model.dart';
import 'package:linguess/features/game/data/repositories/level_repository.dart';

final levelRepositoryProvider = Provider((ref) => LevelRepository());

final levelsProvider = FutureProvider<List<LevelModel>>((ref) async {
  final repo = ref.read(levelRepositoryProvider);
  return repo.fetchLevels();
});
