import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume_state.dart';

final _firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final _authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final _uidProvider = Provider<String>((ref) {
  final u = ref.watch(_authProvider).currentUser;
  if (u == null) throw StateError('Not signed in');
  return u.uid;
});

// Key: target language + category
class ResumeCategoryKey {
  final String targetLang;
  final String categoryId;
  const ResumeCategoryKey(this.targetLang, this.categoryId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResumeCategoryKey &&
          other.targetLang == targetLang &&
          other.categoryId == categoryId);

  @override
  int get hashCode => Object.hash(targetLang, categoryId);

  @override
  String toString() => 'ResumeCategoryKey($targetLang/$categoryId)';
}

class ResumeCategoryRepository {
  ResumeCategoryRepository({
    required this.db,
    required this.uid,
    required this.targetLang,
    required this.categoryId,
  });

  final FirebaseFirestore db;
  final String uid;
  final String targetLang;
  final String categoryId;

  DocumentReference<Map<String, dynamic>> _doc() => db
      .collection('users')
      .doc(uid)
      .collection('targets')
      .doc(targetLang)
      .collection('resume_category')
      .doc(categoryId);

  // Live listening
  Stream<ResumeState?> watch() {
    return _doc().snapshots().map(
      (s) => s.exists ? ResumeState.fromFirestore(s) : null,
    );
  }

  // One-time read
  Future<ResumeState?> fetch() async {
    final s = await _doc().get();
    return s.exists ? ResumeState.fromFirestore(s) : null;
  }

  // Initial setup (when a new word is assigned)
  Future<void> upsertInitial({required String currentWordId}) async {
    await _doc().set({
      'currentWordId': currentWordId,
      'userFilled': <String, String>{}, // empty
      'hintCountUsed': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Write/change a letter (index → "A")
  Future<void> setLetter({required int index, required String ch}) async {
    final up = ch.toUpperCase();
    if (up.isEmpty) {
      await clearLetter(index: index);
      return;
    }
    await _safeUpdate(_doc(), {
      'userFilled.${index.toString()}': up,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a letter (remove index key)
  Future<void> clearLetter({required int index}) async {
    await _safeUpdate(_doc(), {
      'userFilled.${index.toString()}': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Increment hint counter
  Future<void> incrementHintUsed([int by = 1]) async {
    await _safeUpdate(_doc(), {
      'hintCountUsed': FieldValue.increment(by),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Write multiple letters at once
  Future<void> setLettersBulk(Map<int, String> entries) async {
    if (entries.isEmpty) return;
    final patch = <String, dynamic>{};
    entries.forEach((i, ch) {
      final up = ch.toUpperCase();
      patch['userFilled.${i.toString()}'] = up.isEmpty
          ? FieldValue.delete()
          : up;
    });
    patch['updatedAt'] = FieldValue.serverTimestamp();
    await _safeUpdate(_doc(), patch);
  }

  // Safe update to prevent errors if doc does not exist
  Future<void> _safeUpdate(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) async {
    try {
      await ref.update(data);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        await ref.set(data, SetOptions(merge: true));
      } else {
        rethrow;
      }
    }
  }
}

// Providers
final resumeCategoryRepositoryProvider = Provider.family
    .autoDispose<ResumeCategoryRepository, ResumeCategoryKey>((ref, key) {
      return ResumeCategoryRepository(
        db: ref.watch(_firestoreProvider),
        uid: ref.watch(_uidProvider),
        targetLang: key.targetLang,
        categoryId: key.categoryId,
      );
    });

final resumeCategoryStreamProvider = StreamProvider.family
    .autoDispose<ResumeState?, ResumeCategoryKey>((ref, key) {
      return ref.watch(resumeCategoryRepositoryProvider(key)).watch();
    });
