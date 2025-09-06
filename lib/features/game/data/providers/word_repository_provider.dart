import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/game/data/repositories/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(firestore: FirebaseFirestore.instance);
});

final learnedWordIdsProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  // Target language; fallback to 'en' if settings not loaded yet
  final targetLang =
      ref.watch(settingsControllerProvider).value?.targetLangCode ?? 'en';

  if (uid == null) {
    return const Stream<List<String>>.empty();
    // If there is no user, return an empty stream.
  }

  final col = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('targets')
      .doc(targetLang)
      .collection('learnedWords');

  return col.snapshots().map((qs) => qs.docs.map((d) => d.id).toList());
});
