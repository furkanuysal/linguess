import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/repositories/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(firestore: FirebaseFirestore.instance);
});

final learnedWordIdsProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    // If user does not exist, return empty stream
    return const Stream<List<String>>.empty();
  }

  final col = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('learnedWords');

  return col.snapshots().map((qs) => qs.docs.map((d) => d.id).toList());
});
