import 'package:cloud_firestore/cloud_firestore.dart';

// User statistics model
// Firestore: users/{uid}/stats/global Document.
class UserStatsModel {
  final bool? isDailySolved;
  final String? dailyLastSolvedDate;
  final int? dailySolvedCounter;
  final String? lastSolvedWordId;
  final DateTime? lastSolvedAt;

  UserStatsModel({
    this.isDailySolved,
    this.dailyLastSolvedDate,
    this.dailySolvedCounter,
    this.lastSolvedWordId,
    this.lastSolvedAt,
  });

  factory UserStatsModel.fromMap(Map<String, dynamic> map) {
    return UserStatsModel(
      isDailySolved: map['isDailySolved'] as bool?,
      dailyLastSolvedDate: map['dailyLastSolvedDate'] as String?,
      dailySolvedCounter: map['dailySolvedCounter'] as int?,
      lastSolvedWordId: map['lastSolvedWordId'] as String?,
      lastSolvedAt: (map['lastSolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (isDailySolved != null) 'isDailySolved': isDailySolved,
      if (dailyLastSolvedDate != null)
        'dailyLastSolvedDate': dailyLastSolvedDate,
      if (dailySolvedCounter != null) 'dailySolvedCounter': dailySolvedCounter,
      if (lastSolvedWordId != null) 'lastSolvedWordId': lastSolvedWordId,
      if (lastSolvedAt != null) 'lastSolvedAt': lastSolvedAt,
    };
  }
}
