import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/game/data/repositories/daily_puzzle_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final dailyPuzzleRepositoryProvider = Provider<DailyPuzzleRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  return DailyPuzzleRepository(firestore);
});
