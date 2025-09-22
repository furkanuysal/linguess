import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/resume/data/models/resume_state.dart';

final _firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final _uidProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  return userAsync.maybeWhen(data: (u) => u?.uid, orElse: () => null);
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
      'isDefinitionUsed': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearAll() async {
    await _doc().set({
      'currentWordId': '',
      'userFilled': <String, String>{}, // empty
      'hintCountUsed': 0,
      'isDefinitionUsed': false,
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

  // Mark definition as used
  Future<void> markDefinitionUsed(bool value) async {
    await _safeUpdate(_doc(), {
      'isDefinitionUsed': value,
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
final resumeRepositoryProvider = Provider.autoDispose
    .family<ResumeRepository?, ResumeKey>((ref, key) {
      final uid = ref.watch(_uidProvider);
      if (uid == null) return null;
      return ResumeRepository(
        db: ref.watch(_firestoreProvider),
        uid: uid,
        targetLang: key.targetLang,
        gameModeId: key.gameModeId,
      );
    });

final resumeStreamProvider = StreamProvider.autoDispose
    .family<ResumeState?, ResumeKey>((ref, key) {
      final repo = ref.watch(resumeRepositoryProvider(key));
      if (repo == null) {
        return const Stream<ResumeState?>.empty();
      }
      return repo.watch();
    });
