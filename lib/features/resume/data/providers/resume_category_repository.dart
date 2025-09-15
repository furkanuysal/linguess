import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume_state.dart';

final _firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);
final _authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final _uidProvider = Provider<String?>((ref) {
  return ref.watch(_authProvider).currentUser?.uid;
});

// Key: target language + category
class ResumeKey {
  final String targetLang;
  final String gameModeId;
  const ResumeKey(this.targetLang, this.gameModeId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResumeKey &&
          other.targetLang == targetLang &&
          other.gameModeId == gameModeId);

  @override
  int get hashCode => Object.hash(targetLang, gameModeId);

  @override
  String toString() => 'ResumeKey($targetLang/$gameModeId)';
}

class ResumeRepository {
  ResumeRepository({
    required this.db,
    required this.uid,
    required this.targetLang,
    required this.gameModeId,
  });

  final FirebaseFirestore db;
  final String uid;
  final String targetLang;
  final String gameModeId;

  DocumentReference<Map<String, dynamic>> _doc() => db
      .collection('users')
      .doc(uid)
      .collection('targets')
      .doc(targetLang)
      .collection('resume')
      .doc(gameModeId);

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

  Future<void> clearAll() async {
    await _doc().set({
      'currentWordId': '',
      'userFilled': <String, String>{}, // empty
      'hintCountUsed': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));
  }

  Future<void> setCurrentWord(String wordId) async {
    await upsertInitial(currentWordId: wordId);
  }

  // Write/change a letter (index → "A")
  Future<void> setLetter({
    required int index,
    required String ch,
    int? wordLen,
  }) async {
    if (index < 0 || (wordLen != null && index >= wordLen)) return;
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
final resumeRepositoryProvider = Provider.family
    .autoDispose<ResumeRepository, ResumeKey>((ref, key) {
      final uid = ref.watch(_uidProvider);
      if (uid == null) {
        throw StateError('Not signed in');
      }
      return ResumeRepository(
        db: ref.watch(_firestoreProvider),
        uid: uid,
        targetLang: key.targetLang,
        gameModeId: key.gameModeId,
      );
    });

final resumeStreamProvider = StreamProvider.family
    .autoDispose<ResumeState?, ResumeKey>((ref, key) {
      return ref.watch(resumeRepositoryProvider(key)).watch();
    });
