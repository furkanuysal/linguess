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

  final col = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('dailySolved');

  return col.snapshots().map((q) => q.size);
});
