import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';

class UserRegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();

    try {
      final auth = FirebaseAuth.instance;
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await ref.read(userServiceProvider).createUserDocument(user);
      }
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
