import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/providers/auth_provider.dart';
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
  final bool hasUser;
  const ProgressResult({
    required this.learnedCount,
    required this.totalCount,
    required this.hasUser,
  });
}

final progressProvider = FutureProvider.autoDispose
    .family<ProgressResult, ProgressParams>((ref, params) async {
      // Auth state
      final userAsync = ref.watch(firebaseUserProvider);
      final user = userAsync.value;

      // Words (category/level)
      final repo = ref.read(wordRepositoryProvider);
      final List<WordModel> words = params.mode == 'category'
          ? await repo.fetchWordsByCategory(params.id)
          : await repo.fetchWordsByLevel(params.id);

      if (user == null) {
        // Not logged in → only total
        return ProgressResult(
          learnedCount: 0,
          totalCount: words.length,
          hasUser: false,
        );
      }

      // Logged in → read learned word IDs from subcollection
      final learnedSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('learnedWords')
          .get();

      final learnedIds = learnedSnap.docs.map((d) => d.id).toSet();

      final learnedCount = words.where((w) => learnedIds.contains(w.id)).length;

      return ProgressResult(
        learnedCount: learnedCount,
        totalCount: words.length,
        hasUser: true,
      );
    });
