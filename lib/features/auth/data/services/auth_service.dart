import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';

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
      log("Auth sign in error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow; // Trigger the catch blocks for FirebaseAuthException in the UI
    } catch (e, st) {
      log("Auth sign in unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
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
      log("Auth sign up error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth sign up unexpected error: $e", stackTrace: st);
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
      await GoogleSignIn.instance.signOut(); // v7: singleton signout
      await _auth.signOut();
    } on FirebaseAuthException catch (e, st) {
      log("Auth signOut error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth signOut unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // Google Sign-In v7: initialize
  static bool _gInited = false;
  Future<void> _ensureGoogleInit() async {
    if (_gInited) return;
    await GoogleSignIn.instance.initialize();
    _gInited = true;
  }

  // --- Google sign-in-up (Firebase) ---
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureGoogleInit();

      // Interactive sign-in
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: const ['email']);

      // Get idToken
      final idToken = (account.authentication).idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'no-id-token',
          message:
              'Could not retrieve idToken from Google. serverClientId (Web OAuth Client ID) may be required.',
        );
      }

      // Sign in-up with Firebase credential
      final cred = GoogleAuthProvider.credential(idToken: idToken);
      final userCred = await _auth.signInWithCredential(cred);
      final user = userCred.user;
      if (user != null && (userCred.additionalUserInfo?.isNewUser ?? false)) {
        try {
          await ref.read(userServiceProvider).createUserDocument(user);
        } catch (e) {
          // Even if document creation fails, the auth session remains active; just log and continue
          log("createUserDocument failed: $e");
        }
      }

      return user;
    } on FirebaseAuthException catch (e, st) {
      log("Auth googleSignIn error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth googleSignIn unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }
}
