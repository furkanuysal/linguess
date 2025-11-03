import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/features/leveling/data/models/leveling_model.dart';
import 'package:linguess/features/leveling/utils/xp_formula.dart';

class LevelingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LevelingRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _docRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('leveling');
  }

  Future<LevelingModel?> fetchLeveling() async {
    final ref = _docRef;
    if (ref == null) return null;
    final snap = await ref.get();
    if (!snap.exists) return const LevelingModel(level: 1, xp: 0, totalXp: 0);
    return LevelingModel.fromMap(snap.data() ?? {});
  }

  Stream<LevelingModel?> watchLeveling() async* {
    // Wait for auth state changes
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield const LevelingModel(level: 1, xp: 0, totalXp: 0);
        continue;
      }

      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('stats')
          .doc('leveling');

      // Connect Firestore stream (will emit even if doc is created later)
      yield* ref.snapshots().map((snap) {
        if (!snap.exists || snap.data() == null) {
          return const LevelingModel(level: 1, xp: 0, totalXp: 0);
        }
        return LevelingModel.fromMap(snap.data()!);
      });
    }
  }

  // Add XP and handle level-up automatically.
  // Returns the new level if a level-up occurred, otherwise `null`.
  Future<int?> addXp(int amount) async {
    final ref = _docRef;
    if (ref == null) return null;

    final snap = await ref.get();
    final data = snap.data() ?? {};
    int level = (data['level'] ?? 1) as int;
    int xp = (data['xp'] ?? 0) as int;

    xp += amount;
    int requiredXpForLevel = requiredXp(level);

    bool leveledUp = false;
    while (xp >= requiredXpForLevel) {
      xp -= requiredXpForLevel;
      level++;
      leveledUp = true;
      requiredXpForLevel = requiredXp(level);
    }

    await ref.set({
      'level': level,
      'xp': xp,
      'totalXp': FieldValue.increment(amount),
    }, SetOptions(merge: true));

    return leveledUp ? level : null;
  }
}
