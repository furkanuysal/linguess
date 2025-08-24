import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/models/word_model.dart';
import 'package:linguess/providers/achievements_provider.dart';

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

  /// Answered word correct count update.
  /// - users/{uid}/wordProgress/{wordId}.count += 1
  Future<void> onCorrectAnswer({required WordModel word}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final progressRef = userRef.collection('wordProgress').doc(word.id);
    final learnedRef = userRef.collection('learnedWords').doc(word.id);

    bool justLearned = false;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(progressRef);
      final prevCount = (snap.data()?['count'] as int?) ?? 0;
      final newCount = prevCount + 1;

      // wordProgress/{wordId}
      tx.set(progressRef, {
        'count': newCount,
        if (!snap.exists) ...{'firstSeenAt': FieldValue.serverTimestamp()},
      }, SetOptions(merge: true));

      // If count reaches 5, mark as learned
      if (prevCount < 5 && newCount >= 5) {
        justLearned = true;
        tx.set(learnedRef, {
          'learnedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
    if (justLearned) {
      final ach = ref.read(achievementsServiceProvider);
      ach.awardIfNotEarned('learn_firstword');
    }
  }

  /// (Optional helpers)

  /// Current correct count for this word
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

  /// Is this word learned?
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
