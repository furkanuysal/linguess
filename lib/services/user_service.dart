import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref ref;
  UserService(this.ref);

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
        'learnedWords':
            <String>[], // learned words, creating with an empty list
        'achievements': <String>[], // achievements, creating with an empty list
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

  Future<void> handleCorrectAnswer(String word) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() ?? {};
    final Map<String, dynamic> wordProgress = Map<String, dynamic>.from(
      data['wordProgress'] ?? {},
    );
    final List<dynamic> learnedWords = List.from(data['learnedWords'] ?? []);

    final normalizedWord = word.toLowerCase();

    final currentCount = (wordProgress[normalizedWord] ?? 0) + 1;
    wordProgress[normalizedWord] = currentCount;

    if (currentCount >= 5 && !learnedWords.contains(normalizedWord)) {
      learnedWords.add(normalizedWord);
    }

    await userDoc.update({
      'wordProgress': wordProgress,
      'learnedWords': learnedWords,
    });
  }
}
