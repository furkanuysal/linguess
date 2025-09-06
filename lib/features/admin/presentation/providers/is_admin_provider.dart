import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Is the user an admin? users/{uid}.role == "admin"
final isAdminProvider = StreamProvider.autoDispose<bool>((ref) {
  // Listen again when the auth state changes
  final authStream = FirebaseAuth.instance.authStateChanges();

  // If there is no user, return false; if there is, listen to users/{uid}
  return authStream.asyncExpand((user) {
    if (user == null) {
      return Stream<bool>.value(false);
    }
    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
    return docStream.map((snap) {
      final role = (snap.data()?['role'] as String?) ?? 'user';
      return role == 'admin';
    });
  });
});
