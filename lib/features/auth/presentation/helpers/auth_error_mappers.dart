import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AuthErrorMapper {
  static String signIn(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'wrong-password':
        return l10n.errorWrongPassword;
      case 'invalid-credential':
        return l10n.errorInvalidCredential;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorSignInFailed;
    }
  }

  static String signUp(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'email-already-in-use':
        return l10n.errorEmailAlreadyInUse;
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorSignUpFailed;
    }
  }

  static String resetPassword(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'network-request-failed':
        return l10n.errorNetwork;
      default:
        return l10n.errorResetPasswordFailed;
    }
  }
}
