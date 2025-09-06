import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AchievementsService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _userAchCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('achievements');

  // Returns a stream of achievement IDs (as a set) earned by the user
  Stream<Set<String>> earnedIdsStream() {
    final uid = _uid;
    if (uid == null) return const Stream<Set<String>>.empty();
    return _userAchCol(
      uid,
    ).snapshots().map((qs) => qs.docs.map((d) => d.id).toSet());
  }

  // Returns true if the achievement is earned (single read)
  Future<bool> isEarned(String id) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _userAchCol(uid).doc(id).get();
    return doc.exists;
  }

  // If not earned, award it; if already earned, do nothing.
  Future<void> awardIfNotEarned(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = _userAchCol(uid).doc(id);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {'earnedAt': FieldValue.serverTimestamp()});
      }
    });
  }
}
