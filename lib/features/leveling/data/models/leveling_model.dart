class LevelingModel {
  final int level;
  final int xp;
  final int totalXp;

  const LevelingModel({
    required this.level,
    required this.xp,
    required this.totalXp,
  });

  factory LevelingModel.fromMap(Map<String, dynamic> map) {
    return LevelingModel(
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      totalXp: map['totalXp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'level': level, 'xp': xp, 'totalXp': totalXp};
  }

  LevelingModel copyWith({int? level, int? xp, int? totalXp}) {
    return LevelingModel(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXp: totalXp ?? this.totalXp,
    );
  }
}
