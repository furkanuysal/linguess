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
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream<Set<String>>.value(<String>{});
      }
      return _userAchCol(
        user.uid,
      ).snapshots().map((qs) => qs.docs.map((d) => d.id).toSet());
    });
  }

  Stream<Set<String>> unnotifiedIdsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(<String>{});
      return _userAchCol(user.uid)
          .where('notified', isEqualTo: false)
          .snapshots()
          .map((qs) => qs.docs.map((d) => d.id).toSet());
    });
  }

  // Returns true if the achievement is earned (single read)
  Future<bool> isEarned(String id) async {
    final uid = _uid;
    if (uid == null) return false;
    final doc = await _userAchCol(uid).doc(id).get();
    return doc.exists;
  }

  Future<bool> awardIfNotEarned(String id) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final ref = _userAchCol(user.uid).doc(id);
    var created = false;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        created = true;
        tx.set(ref, {
          'earnedAt': FieldValue.serverTimestamp(),
          'notified': false,
        }, SetOptions(merge: false));
      }
    });

    return created;
  }

  Future<void> markNotified(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _userAchCol(uid).doc(id).update({
      'notified': true,
      'notifiedAt': FieldValue.serverTimestamp(),
    });
  }
}
