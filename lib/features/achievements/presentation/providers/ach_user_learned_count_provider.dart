import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';

// Learned words count provider for the current user and target language (reactive).
final achUserLearnedCountProvider = StreamProvider<int>((ref) {
  final userAsync = ref.watch(firebaseUserProvider);
  final targetLang =
      ref.watch(settingsControllerProvider).value?.targetLangCode ?? 'en';

  final user = userAsync.value;
  if (user == null) {
    // User is not logged in → 0
    return Stream<int>.value(0);
  }

  final col = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('targets')
      .doc(targetLang)
      .collection('learnedWords');
  return col.snapshots().map((q) => q.size);
});
