import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/features/stats/data/models/user_stats_model.dart';
import 'package:linguess/core/utils/date_utils.dart';

class GlobalStatsRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _checkedOnce = false; // Is doc checked for existence

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _docRef {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('global');
  }

  // Create document if it doesn't exist (only on first use)
  Future<void> _ensureDocExistsIfMissing() async {
    if (_checkedOnce) return;
    final ref = _docRef;
    if (ref == null) return;

    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'dailySolvedCounter': 0,
        'isDailySolved': false,
        'dailyLastSolvedDate': todayIdLocal(),
      }, SetOptions(merge: true));
    }
    _checkedOnce = true;
  }

  // Watch user stats changes
  Stream<UserStatsModel?> watchUserStats() {
    final ref = _docRef;
    if (ref == null) return const Stream.empty();
    return ref.snapshots().map(
      (snap) => snap.exists ? UserStatsModel.fromMap(snap.data()!) : null,
    );
  }

  // Update last solved word
  Future<void> updateLastSolved(String wordId) async {
    final ref = _docRef;
    if (ref == null) return;

    await _ensureDocExistsIfMissing();

    await ref.set({
      'lastSolvedWordId': wordId,
      'lastSolvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Has user solved today's word?
  Future<bool> hasUserSolvedDaily(String dateId) async {
    final ref = _docRef;
    if (ref == null) return false;

    final snap = await ref.get();
    if (!snap.exists) return false;

    final data = snap.data();
    final isDailySolved = data?['isDailySolved'] == true;
    final dailyLastSolvedDate = data?['dailyLastSolvedDate'] as String?;

    return isDailySolved && dailyLastSolvedDate == dateId;
  }

  // If a new day has started, reset the daily flag
  Future<void> checkDailyReset() async {
    final ref = _docRef;
    if (ref == null) return;

    await _ensureDocExistsIfMissing();

    final todayId = todayIdLocal();
    final snap = await ref.get();

    if (snap.exists) {
      final data = snap.data();
      final dailyLastSolvedDate = data?['dailyLastSolvedDate'] as String?;
      if (dailyLastSolvedDate != todayId) {
        await ref.set({
          'isDailySolved': false,
          'dailyLastSolvedDate': todayId,
        }, SetOptions(merge: true));
      }
    } else {
      await ref.set({
        'isDailySolved': false,
        'dailyLastSolvedDate': todayId,
        'dailySolvedCounter': 0,
      }, SetOptions(merge: true));
    }
  }

  // Increment daily solved counter
  Future<void> incrementDailyCounter(String wordId, String todayId) async {
    final ref = _docRef;
    if (ref == null) return;

    await _ensureDocExistsIfMissing();

    await _firestore.runTransaction((t) async {
      final snap = await t.get(ref);
      final current = (snap.data()?['dailySolvedCounter'] ?? 0) as int;

      t.set(ref, {
        'dailySolvedCounter': current + 1,
        'dailyLastSolvedDate': todayId,
        'isDailySolved': true,
        'lastSolvedWordId': wordId,
        'lastSolvedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // Update time attack high score if the new score is higher
  Future<void> updateTimeAttackHighScore(int newScore) async {
    final ref = _docRef;
    if (ref == null) return;

    await _ensureDocExistsIfMissing();

    await _firestore.runTransaction((t) async {
      final snap = await t.get(ref);
      final current = (snap.data()?['timeAttackHighScore'] ?? 0) as int;
      if (newScore > current) {
        t.set(ref, {'timeAttackHighScore': newScore}, SetOptions(merge: true));
      }
    });
  }
}
