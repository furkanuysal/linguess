import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      if (!kIsWeb) {
        await _ensureGoogleInit();
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
    } catch (e, st) {
      log("Auth signOut unexpected error: $e", stackTrace: st);
    }
  }

  User? get currentUser => _auth.currentUser;

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
      if (kIsWeb) {
        // Web version
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.setCustomParameters({'prompt': 'select_account'});

        final userCred = await _auth.signInWithPopup(provider);
        final user = userCred.user;

        if (user != null && (userCred.additionalUserInfo?.isNewUser ?? false)) {
          try {
            await ref.read(userServiceProvider).createUserDocument(user);
          } catch (e) {
            log("createUserDocument (Google Web) failed: $e");
          }
        }

        return user;
      } else {
        //  Mobile version
        await _ensureGoogleInit();

        final GoogleSignInAccount account = await GoogleSignIn.instance
            .authenticate(scopeHint: const ['email']);

        final idToken = (account.authentication).idToken;
        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'no-id-token',
            message:
                'Could not retrieve idToken from Google. serverClientId (Web OAuth Client ID) may be required.',
          );
        }

        final cred = GoogleAuthProvider.credential(idToken: idToken);
        final userCred = await _auth.signInWithCredential(cred);
        final user = userCred.user;

        if (user != null && (userCred.additionalUserInfo?.isNewUser ?? false)) {
          try {
            await ref.read(userServiceProvider).createUserDocument(user);
          } catch (e) {
            log("createUserDocument (Google Mobile) failed: $e");
          }
        }

        return user;
      }
    } on FirebaseAuthException catch (e, st) {
      log("Auth googleSignIn error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth googleSignIn unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }

  // GitHub Sign-In (Web + Mobile)
  Future<User?> signInWithGitHub() async {
    try {
      final provider = GithubAuthProvider();
      provider.addScope('read:user');
      provider.addScope('user:email');

      final userCred = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      final user = userCred.user;

      if (user != null && (userCred.additionalUserInfo?.isNewUser ?? false)) {
        try {
          await ref.read(userServiceProvider).createUserDocument(user);
        } catch (e) {
          log("createUserDocument (GitHub) failed: $e");
        }
      }

      return user;
    } on FirebaseAuthException catch (e, st) {
      log("Auth githubSignIn error: [${e.code}] ${e.message}", stackTrace: st);
      rethrow;
    } catch (e, st) {
      log("Auth githubSignIn unexpected error: $e", stackTrace: st);
      rethrow;
    }
  }
}
