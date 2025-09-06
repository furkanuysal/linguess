import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/data/repositories/daily_puzzle_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final dailyPuzzleRepositoryProvider = Provider<DailyPuzzleRepository>((ref) {
  return DailyPuzzleRepository(ref.read(firestoreProvider));
});

// Today ID
String todayIdLocal() {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y$m$d';
}

final todayIdProvider = Provider<String>((ref) => todayIdLocal());

// Did the user solve today's puzzle?
final dailySolvedProvider = StreamProvider<bool>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream<bool>.empty();
  final todayId = ref.watch(todayIdProvider);
  final doc = ref
      .read(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('dailySolved')
      .doc(todayId);
  return doc.snapshots().map((snap) => snap.exists);
});

// Handle daily button press
Future<void> handleDailyButton(BuildContext context, WidgetRef ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  // If not logged in: show snackbar and return
  if (uid == null) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.dailyWordLoginRequired),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final todayId = ref.read(todayIdProvider);
  final snap = await ref
      .read(firestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('dailySolved')
      .doc(todayId)
      .get();

  if (snap.exists) {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            '🎯 ${AppLocalizations.of(context)!.dailyWordCompletedTitleAlert}',
          ),
          content: Text(
            AppLocalizations.of(context)!.dailyWordCompletedBodyAlert,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context)!.okay),
            ),
          ],
        ),
      );
    }
    return;
  }

  if (context.mounted) {
    context.push('/game/daily/$todayId');
  }
}
