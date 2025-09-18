import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/utils/locale_utils.dart';

class DailyEntry {
  final String id; // "20250811"
  final String wordId;
  final DateTime date; // date generated from id
  final DateTime? createdAt;

  DailyEntry({
    required this.id,
    required this.wordId,
    required this.date,
    required this.createdAt,
  });

  static DateTime _parseYyyyMmDd(String id) {
    // "20250811" → DateTime(2025, 08, 11)
    final y = int.parse(id.substring(0, 4));
    final m = int.parse(id.substring(4, 6));
    final d = int.parse(id.substring(6, 8));
    return DateTime(y, m, d);
  }

  factory DailyEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return DailyEntry(
      id: doc.id,
      wordId: (data['wordId'] ?? '') as String,
      date: _parseYyyyMmDd(doc.id),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}

// Daily list — if createdAt exists, sort by it, otherwise by id (yyyyMMdd) DESC
final dailyListProvider = StreamProvider<List<DailyEntry>>((ref) async* {
  final snapshots = FirebaseFirestore.instance
      .collection('daily')
      .orderBy('createdAt', descending: true)
      .snapshots();

  await for (final snap in snapshots) {
    final items = snap.docs.map((d) => DailyEntry.fromDoc(d)).toList();

    // If createdAt is equal/missing, break tie with date derived from id
    items.sort((a, b) {
      final aMillis = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bMillis = b.createdAt?.millisecondsSinceEpoch ?? 0;
      if (aMillis != bMillis) {
        return bMillis.compareTo(aMillis); // createdAt DESC
      }
      return b.date.compareTo(a.date); // Date derived from yyyyMMdd id DESC
    });

    yield items;
  }
});

// wordId -> words/{wordId}.locales.en.term
final wordEnByIdProvider = FutureProvider.family<String?, String>((
  ref,
  wordId,
) async {
  if (wordId.isEmpty) return null;

  final doc = await FirebaseFirestore.instance
      .collection('words')
      .doc(wordId)
      .get();

  if (!doc.exists) return null;

  final data = doc.data();
  if (data == null) return null;

  final en = data.termOf('en');
  return en.isEmpty ? null : en;
});
