import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EconomyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Power-up costs
  static const int revealLetterCost = 2;
  static const int showDefinitionCost = 3;
  static const int showExampleSentenceCost = 3;

  static const int showExampleSentenceTargetCost = 7;
  static const int skipWordCost = 8;

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

    final int goldToAdd = computeSolveReward(hintCountUsed);
    if (goldToAdd <= 0) return;

    final userDoc = _firestore.collection('users').doc(uid);
    final globalStatsDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('global');

    final updates = <String, dynamic>{
      'correctCount': FieldValue.increment(1),
      'gold': FieldValue.increment(goldToAdd),
    };

    await Future.wait([
      userDoc.update(updates),
      globalStatsDoc.set({
        'totalGoldEarned': FieldValue.increment(goldToAdd),
      }, SetOptions(merge: true)),
    ]);
  }

  // Ad reward: atomically adds the specified amount of gold.
  Future<void> grantAdRewardGold(int amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || amount <= 0) return;

    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({'gold': FieldValue.increment(amount)});
  }

  // Adds gold (e.g., for Time Attack or other gameplay rewards) and updates totalGoldEarned.
  Future<void> addGold(int amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || amount <= 0) return;

    final userDoc = _firestore.collection('users').doc(uid);
    final globalStatsDoc = _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('global');

    await Future.wait([
      userDoc.update({
        'gold': FieldValue.increment(amount),
        'correctCount': FieldValue.increment(1),
      }),
      globalStatsDoc.set({
        'totalGoldEarned': FieldValue.increment(amount),
      }, SetOptions(merge: true)),
    ]);
  }

  // 0 hint = +5, 1–2 hint = +2, 3+ = +1
  int computeSolveReward(int hintsUsed) {
    if (hintsUsed <= 0) return 5;
    if (hintsUsed <= 2) return 2;
    return 1;
  }
}
