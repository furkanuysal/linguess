import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EconomyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> getUserGold() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['gold'] ?? 0;
  }

  Future<bool> tryUseHint() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();
    int gold = userSnapshot.data()?['gold'] ?? 0;

    if (gold < 5) return false;

    await userDoc.update({'gold': gold - 5});
    return true;
  }

  Future<void> rewardGold(int hintCountUsed) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    int goldToAdd = 0;

    if (hintCountUsed == 0) {
      goldToAdd = 3;
    } else if (hintCountUsed == 1 || hintCountUsed == 2) {
      goldToAdd = 1;
    } else {
      goldToAdd = 0;
    }

    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();
    int currentGold = userSnapshot.data()?['gold'] ?? 0;

    await userDoc.update({'gold': currentGold + goldToAdd});
  }
}
