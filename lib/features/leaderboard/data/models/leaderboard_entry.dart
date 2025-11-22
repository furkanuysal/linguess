class LeaderboardEntry {
  final String uid;
  final String? displayName;
  final String? maskedEmail;
  final int correctCount;

  LeaderboardEntry({
    required this.uid,
    this.displayName,
    this.maskedEmail,
    required this.correctCount,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String uid) {
    return LeaderboardEntry(
      uid: uid,
      displayName: map['displayName'] as String?,
      maskedEmail: map['maskedEmail'] as String?,
      correctCount: (map['correctCount'] as int?) ?? 0,
    );
  }

  String get formattedName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return maskedEmail ?? 'Anonymous';
  }

  static String maskEmail(String? email) {
    if (email == null || email.isEmpty) return 'Anonymous';
    final parts = email.split('@');
    if (parts.isEmpty) return 'Anonymous';
    final namePart = parts[0];
    if (namePart.length > 5) {
      return '${namePart.substring(0, 5)}*****';
    } else {
      return '$namePart*****';
    }
  }
}
