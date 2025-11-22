import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/data/models/word_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/leaderboard/data/models/leaderboard_entry.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;
  UserService(this.ref);

  // New user document creation
  Future<void> createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    final displayName = docSnapshot.data()?['displayName'] as String?;

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'gold': 0,
        'correctCount': 0,
        'role': 'user',
      });

      // Create public leaderboard entry
      await _firestore.collection('leaderboard').doc(user.uid).set({
        'uid': user.uid,
        if (displayName != null) 'displayName': displayName,
        'maskedEmail': LeaderboardEntry.maskEmail(user.email),
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

  // Update correct answer count under target language
  // - users/{uid}/targets/{targetLang}/wordProgress/{wordId}.count += 1
  // - When it reaches 5, create users/{uid}/targets/{targetLang}/learnedWords/{wordId}
  Future<void> onCorrectAnswer({
    required WordModel word,
    required String targetLang,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);
    final leaderboardRef = _firestore.collection('leaderboard').doc(uid);
    final targetDocRef = userRef.collection('targets').doc(targetLang);
    final progressRef = targetDocRef.collection('wordProgress').doc(word.id);
    final learnedRef = targetDocRef.collection('learnedWords').doc(word.id);

    var justLearned = false;

    await _firestore.runTransaction((tx) async {
      // Read first
      final userSnap = await tx.get(userRef);
      final targetSnap = await tx.get(targetDocRef);
      final progressSnap = await tx.get(progressRef);

      final prevCount = (progressSnap.data()?['count'] as int?) ?? 0;
      final newCount = prevCount + 1;

      final currentGlobalCount =
          (userSnap.data()?['correctCount'] as int?) ?? 0;
      final newGlobalCount = currentGlobalCount + 1;
      final displayName = userSnap.data()?['displayName'] as String?;
      final currentUser = FirebaseAuth.instance.currentUser;

      // Then write
      tx.update(userRef, {'correctCount': newGlobalCount});

      tx.set(leaderboardRef, {
        'correctCount': newGlobalCount,
        'maskedEmail': LeaderboardEntry.maskEmail(currentUser?.email),
        if (displayName != null) 'displayName': displayName,
        'uid': uid,
      }, SetOptions(merge: true));

      if (!targetSnap.exists) {
        tx.set(targetDocRef, {
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      tx.set(progressRef, {
        'count': newCount,
        if (!progressSnap.exists) 'firstSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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

  // The correct answer count for the word under the target language
  Future<int> getProgressCount(String wordId, String targetLang) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('targets')
        .doc(targetLang)
        .collection('wordProgress')
        .doc(wordId)
        .get();
    return (doc.data()?['count'] as int?) ?? 0;
  }

  // Is the word has been learned under the target language?
  Future<bool> isLearned(String wordId, String targetLang) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('targets')
        .doc(targetLang)
        .collection('learnedWords')
        .doc(wordId)
        .get();
    return doc.exists;
  }

  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('leaderboard')
          .orderBy('correctCount', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        return LeaderboardEntry.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      log("Error fetching leaderboard: $e");
      return [];
    }
  }
}
