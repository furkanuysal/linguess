enum AchievementProgressType {
  solvedWordsTotal, // userCorrectCountProvider
  learnedWordsTotal, // userLearnedCountProvider
  dailySolvedTotal, // userDailySolvedCountProvider
}

sealed class AchievementReward {
  const AchievementReward();
}

class GoldReward extends AchievementReward {
  final int amount;
  const GoldReward(this.amount);
}

class ItemReward extends AchievementReward {
  final String itemId;
  const ItemReward(this.itemId);
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool hasProgress;

  final AchievementProgressType? progressType; // null if hasProgress is false
  final int? progressTarget; // null if hasProgress is false

  final AchievementReward? reward;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.hasProgress,
    this.progressType,
    this.progressTarget,
    this.reward,
  });

  const AchievementModel.withEmptyValues({
    required this.id,
    required this.hasProgress,
    this.progressType,
    this.progressTarget,
    this.reward,
    // Empty icon, title ve description
  }) : title = '',
       description = '',
       icon = '';

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? hasProgress,
    AchievementProgressType? progressType,
    int? progressTarget,
    AchievementReward? reward,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      hasProgress: hasProgress ?? this.hasProgress,
      progressType: progressType ?? this.progressType,
      progressTarget: progressTarget ?? this.progressTarget,
      reward: reward ?? this.reward,
    );
  }
}
