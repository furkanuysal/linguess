import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EconomyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Power-up costs
  static const int showDefinitionCost = 3;
  static const int revealLetterCost = 5;
  static const int skipWordCost = 10;

  Future<int> getUserGold() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return (doc.data()?['gold'] as int?) ?? 0;
  }

  // Use a hint: if gold >= hintCost, decrement and return true, else false.
  // Condition: check + decrement with transaction.
  Future<bool> trySpendGold(int goldCost) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final userDoc = _firestore.collection('users').doc(uid);

    try {
      return await _firestore.runTransaction<bool>((tx) async {
        final snap = await tx.get(userDoc);
        if (!snap.exists) return false;

        final currentGold = (snap.data()?['gold'] as int?) ?? 0;
        if (currentGold < goldCost) return false;

        tx.update(userDoc, {'gold': FieldValue.increment(-goldCost)});
        return true;
      });
    } catch (_) {
      return false;
    }
  }

  // Solve reward: adds gold based on hint count used, increments correctCount by 1.
  // Atomic: uses increment in a single update.
  Future<void> rewardGold(int hintCountUsed) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final int goldToAdd = _computeSolveReward(hintCountUsed);

    final userDoc = _firestore.collection('users').doc(uid);
    final updates = <String, dynamic>{'correctCount': FieldValue.increment(1)};
    if (goldToAdd > 0) {
      updates['gold'] = FieldValue.increment(goldToAdd);
    }

    await userDoc.update(updates);
  }

  // Ad reward: atomically adds the specified amount of gold.
  Future<void> grantAdRewardGold(int amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || amount <= 0) return;

    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({'gold': FieldValue.increment(amount)});
  }

  // 0 hint = +5, 1–2 hint = +2, 3+ = +1
  int _computeSolveReward(int hintsUsed) {
    if (hintsUsed <= 0) return 5;
    if (hintsUsed <= 2) return 2;
    return 1;
  }
}
