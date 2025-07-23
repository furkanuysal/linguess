import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/controllers/user_register_controller.dart';
import 'package:linguess/providers/auth_provider.dart';
import 'package:linguess/services/user_service.dart';

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

final userRegisterProvider =
    AsyncNotifierProvider<UserRegisterController, void>(
      UserRegisterController.new,
    );
