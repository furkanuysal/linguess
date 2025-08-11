// lib/providers/progress_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/providers/user_data_provider.dart';
import 'package:linguess/providers/word_repository_provider.dart';
import 'package:linguess/models/word_model.dart';

class ProgressParams {
  final String mode; // 'category' or 'level'
  final String id; // categoryId or levelId
  const ProgressParams({required this.mode, required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressParams && other.mode == mode && other.id == id;

  @override
  int get hashCode => Object.hash(mode, id);
}

class ProgressResult {
  final int learnedCount;
  final int totalCount;
  const ProgressResult({required this.learnedCount, required this.totalCount});
}

final progressProvider = FutureProvider.family<ProgressResult, ProgressParams>((
  ref,
  params,
) async {
  final userSnap = await ref.watch(userDataProvider.future);
  final learnedIds = userSnap != null && userSnap.exists
      ? List<String>.from(
          (userSnap.data() as Map<String, dynamic>)['learnedWords'] ?? const [],
        )
      : const <String>[];

  final repo = ref.read(wordRepositoryProvider);
  List<WordModel> words;
  if (params.mode == 'category') {
    words = await repo.fetchWordsByCategory(params.id);
  } else {
    words = await repo.fetchWordsByLevel(params.id);
  }

  final learnedCount = words.where((w) => learnedIds.contains(w.id)).length;

  return ProgressResult(learnedCount: learnedCount, totalCount: words.length);
});
