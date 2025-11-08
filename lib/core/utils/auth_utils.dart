import 'package:firebase_auth/firebase_auth.dart';

// Check if the user signed in with email/password.
// If the user is null, return false.
bool isPasswordUser(User? user) {
  if (user == null) return false;
  return user.providerData.any((info) => info.providerId == 'password');
}

// Check if the user signed in with an external provider (Google, Apple, etc.).
bool isExternalUser(User? user) {
  if (user == null) return false;
  return user.providerData.any((info) => info.providerId != 'password');
}

// Check if a user is currently signed in.
bool isSignedIn() => FirebaseAuth.instance.currentUser != null;

// Get the current signed-in user, or null if no user is signed in.
User? currentUser() => FirebaseAuth.instance.currentUser;
