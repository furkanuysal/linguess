import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/game/data/repositories/word_repository.dart';
import 'package:linguess/features/game/data/models/word_model.dart';
import 'package:linguess/core/utils/locale_utils.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(firestore: FirebaseFirestore.instance);
});

class LearnedWordDisplay {
  final WordModel word;
  final DateTime? learnedAt;

  LearnedWordDisplay({required this.word, this.learnedAt});
}

final learnedWordIdsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final userAsync = ref.watch(firebaseUserProvider);
      final user = userAsync.value;

      // Target language; fallback to 'en' if settings not loaded yet
      final targetLang =
          ref.watch(settingsControllerProvider).value?.targetLangCode ?? 'en';

      if (user == null) {
        return Stream.value([]);
        // If there is no user, return an empty list stream to stop loading.
      }

      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('targets')
          .doc(targetLang)
          .collection('learnedWords');

      return col.snapshots().map((qs) {
        return qs.docs.map((d) {
          final data = d.data();
          return {
            'id': d.id,
            'learnedAt': (data['learnedAt'] as Timestamp?)?.toDate(),
          };
        }).toList();
      });
    });

final learnedWordsDetailsProvider =
    FutureProvider.autoDispose<List<LearnedWordDisplay>>((ref) async {
      final learnedData = await ref.watch(learnedWordIdsProvider.future);
      if (learnedData.isEmpty) return [];

      final repo = ref.watch(wordRepositoryProvider);
      final targetLang =
          ref.watch(settingsControllerProvider).value?.targetLangCode ?? 'en';

      final ids = learnedData.map((d) => d['id'] as String).toList();
      final list = await Future.wait(ids.map(repo.fetchWordById));

      final words = <LearnedWordDisplay>[];
      for (var i = 0; i < list.length; i++) {
        final w = list[i];
        if (w != null) {
          words.add(
            LearnedWordDisplay(
              word: w,
              learnedAt: learnedData[i]['learnedAt'] as DateTime?,
            ),
          );
        }
      }

      words.sort((a, b) {
        final ta = (a.word.termOf(targetLang)).toLowerCase();
        final tb = (b.word.termOf(targetLang)).toLowerCase();
        return ta.compareTo(tb);
      });

      return words;
    });
