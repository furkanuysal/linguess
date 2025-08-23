import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/models/word_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;
  UserService(this.ref);

  // New user document creation
  Future<void> createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'gold': 0,
        'correctCount': 0,
      });
    }
  }

  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      log("Error updating user document: $e");
    }
  }

  Future<DocumentSnapshot> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      log("Error fetching user document: $e");
      rethrow;
    }
  }

  /// Doğru cevap sonrası sayaç güncelleme.
  /// - users/{uid}/wordProgress/{wordId}.count += 1
  /// - 5'e ulaştıysa users/{uid}/learnedWords/{wordId} oluşturulur/merge edilir
  Future<void> onCorrectAnswer({required WordModel word}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final progressRef = userRef.collection('wordProgress').doc(word.id);
    final learnedRef = userRef.collection('learnedWords').doc(word.id);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(progressRef);
      final prevCount = (snap.data()?['count'] as int?) ?? 0;
      final newCount = prevCount + 1;

      // wordProgress/{wordId}
      tx.set(progressRef, {
        'count': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snap.exists) ...{'firstSeenAt': FieldValue.serverTimestamp()},
      }, SetOptions(merge: true));

      // 5'e ulaşınca learnedWords/{wordId}
      if (newCount >= 5) {
        tx.set(learnedRef, {
          'learnedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  /// (İsteğe bağlı yardımcılar)

  /// Bu kelime için mevcut doğru sayısı
  Future<int> getProgressCount(String wordId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wordProgress')
        .doc(wordId)
        .get();
    return (doc.data()?['count'] as int?) ?? 0;
  }

  /// Bu kelime öğrenilmiş mi?
  Future<bool> isLearned(String wordId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('learnedWords')
        .doc(wordId)
        .get();
    return doc.exists;
  }
}
