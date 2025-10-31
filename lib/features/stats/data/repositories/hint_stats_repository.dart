import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HintStatsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HintStatsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Access the user's "users/{uid}/stats/hints" document.
  DocumentReference<Map<String, dynamic>>? get _docRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('hints');
  }

  // Increments usage of a specific power-up type.
  // type parameter: 'revealLetter', 'showDefinition', 'showExampleSentence', 'skipWord', etc.
  Future<void> incrementHintUsage(String type, [int count = 1]) async {
    final ref = _docRef;
    if (ref == null) return;

    await ref.set({type: FieldValue.increment(count)}, SetOptions(merge: true));
  }

  // Returns all hint statistics.
  Future<Map<String, dynamic>?> fetchAll() async {
    final ref = _docRef;
    if (ref == null) return null;
    final snap = await ref.get();
    return snap.data();
  }

  // Watch as a stream (e.g., to display live on the profile page)
  Stream<Map<String, dynamic>?> watchHintUsage() {
    final ref = _docRef;
    if (ref == null) return const Stream.empty();
    return ref.snapshots().map((snap) => snap.data());
  }
}
