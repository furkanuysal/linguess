import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';

// Total daily solved count provider for the current user
final achUserDailySolvedCountProvider = StreamProvider<int>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  final user = userAsync.value;
  if (user == null) {
    return Stream<int>.value(0);
  }

  final doc = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('stats')
      .doc('global');

  return doc.snapshots().map((snap) {
    final data = snap.data();
    if (data == null) return 0;
    return (data['dailySolvedCounter'] ?? 0) as int;
  });
});
