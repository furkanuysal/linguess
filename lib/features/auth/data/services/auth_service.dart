import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';

class AuthService {
  final Ref ref;
  AuthService(this.ref);

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e, st) {
      log("Auth signIn error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow; // Trigger the catch blocks for FirebaseAuthException in the UI
    } catch (e, st) {
      log("Auth signIn unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e, st) {
      log("Auth register error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth register unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, st) {
      log("Auth resetPassword error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth resetPassword unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e, st) {
      log("Auth signOut error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth signOut unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // Get current user
  User? getCurrentUser() => _auth.currentUser;
}
