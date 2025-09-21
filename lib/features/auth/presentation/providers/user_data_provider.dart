import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/auth/presentation/controllers/user_sign_up_controller.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/data/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref);
});

final userDataProvider = StreamProvider.autoDispose<DocumentSnapshot?>((ref) {
  final user = ref.watch(firebaseUserProvider).value;
  if (user == null) return const Stream.empty();

  final docStream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots();

  return docStream;
});

final userCorrectCountProvider = StreamProvider.autoDispose<int>((ref) {
  final user = ref.watch(firebaseUserProvider).value;
  if (user == null) {
    return const Stream<int>.empty();
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return 0;
        final data = doc.data();
        return (data?['correctCount'] as int?) ?? 0;
      });
});

final userSignUpProvider = AsyncNotifierProvider<UserSignUpController, void>(
  UserSignUpController.new,
);
