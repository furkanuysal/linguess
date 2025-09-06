import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyPuzzleRepository {
  DailyPuzzleRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// Get today's date ID in YYYYMMDD format
  String todayIdLocal({DateTime? now}) {
    final n = now ?? DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}';
  }

  /// If documents have a 'rand' (0..1) field, it uses it for fairer random selection;
  /// if not, it falls back to "get first 50 + shuffle".
  Future<String> _pickRandomWordId() async {
    try {
      final r = Random().nextDouble();
      final q1 = await _firestore
          .collection('words')
          .orderBy('rand')
          .startAt([r])
          .limit(1)
          .get();

      if (q1.docs.isNotEmpty) {
        return q1.docs.first.id;
      }

      final q2 = await _firestore
          .collection('words')
          .orderBy('rand')
          .limit(1)
          .get();

      if (q2.docs.isNotEmpty) {
        return q2.docs.first.id;
      }
    } catch (_) {
      // If 'rand' field is missing or index is not found, fallback
    }

    // Fallback: Get first 50 words and shuffle
    final snap = await _firestore.collection('words').limit(50).get();
    if (snap.docs.isEmpty) {
      throw Exception('No words in collection');
    }
    final docs = snap.docs.toList()..shuffle();
    return docs.first.id;
  }

  /// If the daily document does not exist, it creates it atomically; if it does, it returns the existing wordId.
  Future<String> getOrCreateTodayDailyWordId() async {
    final id = todayIdLocal();
    final docRef = _firestore.collection('daily').doc(id);
    final candidateWordId = await _pickRandomWordId();

    return _firestore.runTransaction((tx) async {
      final doc = await tx.get(docRef);
      if (doc.exists) {
        final wordId = doc.data()?['wordId'] as String?;
        if (wordId == null || wordId.isEmpty) {
          throw Exception('Daily doc exists but wordId is missing');
        }
        return wordId;
      } else {
        tx.set(docRef, {
          'wordId': candidateWordId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return candidateWordId;
      }
    });
  }

  /// Document referance
  DocumentReference<Map<String, dynamic>> todayDailyDocRef() {
    final id = todayIdLocal();
    return _firestore.collection('daily').doc(id);
  }
}
