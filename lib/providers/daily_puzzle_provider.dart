import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/daily_puzzle_repository.dart';
import '../pages/word_game_page.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final dailyPuzzleRepositoryProvider = Provider<DailyPuzzleRepository>((ref) {
  return DailyPuzzleRepository(ref.read(firestoreProvider));
});

// --- Bugünün ID'si ---
String todayIdLocal() {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y$m$d';
}

final todayIdProvider = Provider<String>((ref) => todayIdLocal());

// --- Çözüldü mü? ---
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

// --- Ana sayfadan buton tıklanınca çağrılır ---
Future<void> handleDailyButton(BuildContext context, WidgetRef ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

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
          title: const Text('🎯 Günlük Kelime Tamamlandı'),
          content: const Text(
            'Bugünün kelimesini çözdünüz. Yeni kelime yarın!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
    return;
  }

  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordGamePage(selectedValue: todayId, mode: 'daily'),
      ),
    );
  }
}
