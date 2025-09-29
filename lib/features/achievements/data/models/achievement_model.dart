enum AchievementProgressType {
  solvedWordsTotal, // userCorrectCountProvider
  learnedWordsTotal, // userLearnedCountProvider
  dailySolvedTotal, // userDailySolvedCountProvider
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool hasProgress;

  final AchievementProgressType? progressType; // null if hasProgress is false
  final int? progressTarget; // null if hasProgress is false

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.hasProgress,
    this.progressType,
    this.progressTarget,
  });
}
