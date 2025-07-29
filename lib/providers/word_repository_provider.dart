import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/repositories/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(firestore: FirebaseFirestore.instance);
});
