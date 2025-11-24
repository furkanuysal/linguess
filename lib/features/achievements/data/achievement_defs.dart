import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';

// Static definitions for logic (ID, Reward, Progress)
// Title/Description/Icon are placeholders here and populated in buildAchievements
final achievementDefinitions = <String, AchievementModel>{
  'solve_firstword': const AchievementModel.withEmptyValues(
    id: 'solve_firstword',
    hasProgress: true,
    progressType: AchievementProgressType.solvedWordsTotal,
    progressTarget: 1,
    reward: GoldReward(10),
  ),
  'solve_firstword_nohint': const AchievementModel.withEmptyValues(
    id: 'solve_firstword_nohint',
    hasProgress: false,
    reward: GoldReward(10),
  ),
  'solve_dailyword_first_time': const AchievementModel.withEmptyValues(
    id: 'solve_dailyword_first_time',
    hasProgress: false,
    reward: GoldReward(10),
  ),
  'learn_firstword': const AchievementModel.withEmptyValues(
    id: 'learn_firstword',
    hasProgress: false,
    reward: GoldReward(20),
  ),
  'used_definition_powerup_first_time': const AchievementModel.withEmptyValues(
    id: 'used_definition_powerup_first_time',
    hasProgress: false,
    reward: GoldReward(5),
  ),
  'used_hint_powerup_first_time': const AchievementModel.withEmptyValues(
    id: 'used_hint_powerup_first_time',
    hasProgress: false,
    reward: GoldReward(5),
  ),
  'used_skip_powerup_first_time': const AchievementModel.withEmptyValues(
    id: 'used_skip_powerup_first_time',
    hasProgress: false,
    reward: GoldReward(5),
  ),
  'used_example_sentence_powerup_first_time':
      const AchievementModel.withEmptyValues(
        id: 'used_example_sentence_powerup_first_time',
        hasProgress: false,
        reward: GoldReward(5),
      ),
  'used_example_sentence_target_powerup_first_time':
      const AchievementModel.withEmptyValues(
        id: 'used_example_sentence_target_powerup_first_time',
        hasProgress: false,
        reward: GoldReward(5),
      ),
  'solve_dailyword_ten_times': const AchievementModel.withEmptyValues(
    id: 'solve_dailyword_ten_times',
    hasProgress: true,
    progressType: AchievementProgressType.dailySolvedTotal,
    progressTarget: 10,
    reward: GoldReward(50),
  ),
  'solve_dailyword_thirty_times': const AchievementModel.withEmptyValues(
    id: 'solve_dailyword_thirty_times',
    hasProgress: true,
    progressType: AchievementProgressType.dailySolvedTotal,
    progressTarget: 30,
    reward: GoldReward(100),
  ),
  'solve_ten_words': const AchievementModel.withEmptyValues(
    id: 'solve_ten_words',
    hasProgress: true,
    progressType: AchievementProgressType.solvedWordsTotal,
    progressTarget: 10,
    reward: GoldReward(20),
  ),
  'solve_fifty_words': const AchievementModel.withEmptyValues(
    id: 'solve_fifty_words',
    hasProgress: true,
    progressType: AchievementProgressType.solvedWordsTotal,
    progressTarget: 50,
    reward: GoldReward(30),
  ),
  'solve_hundred_words': const AchievementModel.withEmptyValues(
    id: 'solve_hundred_words',
    hasProgress: true,
    progressType: AchievementProgressType.solvedWordsTotal,
    progressTarget: 100,
    reward: GoldReward(50),
  ),
  'solve_fivehundred_words': const AchievementModel.withEmptyValues(
    id: 'solve_fivehundred_words',
    hasProgress: true,
    progressType: AchievementProgressType.solvedWordsTotal,
    progressTarget: 500,
    reward: GoldReward(100),
  ),
  'solve_thousand_words': const AchievementModel.withEmptyValues(
    id: 'solve_thousand_words',
    hasProgress: true,
    progressType: AchievementProgressType.solvedWordsTotal,
    progressTarget: 1000,
    reward: GoldReward(200),
  ),
  'learn_ten_words': const AchievementModel.withEmptyValues(
    id: 'learn_ten_words',
    hasProgress: true,
    progressType: AchievementProgressType.learnedWordsTotal,
    progressTarget: 10,
    reward: GoldReward(50),
  ),
  'learn_twenty_words': const AchievementModel.withEmptyValues(
    id: 'learn_twenty_words',
    hasProgress: true,
    progressType: AchievementProgressType.learnedWordsTotal,
    progressTarget: 20,
    reward: GoldReward(100),
  ),
  // TODO: Add more achievements with rewards
};

List<AchievementModel> buildAchievements(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  AchievementModel build(String id, String title, String desc) {
    final def = achievementDefinitions[id];
    if (def == null) {
      // Fallback if definition missing (should not happen)
      return AchievementModel(
        id: id,
        title: title,
        description: desc,
        icon: '/empty',
        hasProgress: false,
      );
    }
    return def.copyWith(title: title, description: desc);
  }

  return [
    build(
      'solve_firstword',
      l10n.achievement_solve_firstword_title,
      l10n.achievement_solve_firstword_description,
    ),
    build(
      'solve_firstword_nohint',
      l10n.achievement_solve_firstword_nohint_title,
      l10n.achievement_solve_firstword_nohint_description,
    ),
    build(
      'solve_dailyword_first_time',
      l10n.achievement_solve_dailyword_first_time_title,
      l10n.achievement_solve_dailyword_first_time_description,
    ),
    build(
      'learn_firstword',
      l10n.achievement_learn_firstword_title,
      l10n.achievement_learn_firstword_description,
    ),
    build(
      'used_definition_powerup_first_time',
      l10n.achievement_used_definition_powerup_first_time_title,
      l10n.achievement_used_definition_powerup_first_time_description,
    ),
    build(
      'used_hint_powerup_first_time',
      l10n.achievement_used_hint_powerup_first_time_title,
      l10n.achievement_used_hint_powerup_first_time_description,
    ),
    build(
      'used_skip_powerup_first_time',
      l10n.achievement_used_skip_powerup_first_time_title,
      l10n.achievement_used_skip_powerup_first_time_description,
    ),
    build(
      'used_example_sentence_powerup_first_time',
      l10n.achievement_used_example_sentence_powerup_first_time_title,
      l10n.achievement_used_example_sentence_powerup_first_time_description,
    ),
    build(
      'used_example_sentence_target_powerup_first_time',
      l10n.achievement_used_example_sentence_target_powerup_first_time_title,
      l10n.achievement_used_example_sentence_target_powerup_first_time_description,
    ),
    build(
      'solve_dailyword_ten_times',
      l10n.achievement_solve_dailyword_ten_times_title,
      l10n.achievement_solve_dailyword_ten_times_description,
    ),
    build(
      'solve_dailyword_thirty_times',
      l10n.achievement_solve_dailyword_thirty_times_title,
      l10n.achievement_solve_dailyword_thirty_times_description,
    ),
    build(
      'solve_ten_words',
      l10n.achievement_solve_ten_words_title,
      l10n.achievement_solve_ten_words_description,
    ),
    build(
      'solve_fifty_words',
      l10n.achievement_solve_fifty_words_title,
      l10n.achievement_solve_fifty_words_description,
    ),
    build(
      'solve_hundred_words',
      l10n.achievement_solve_hundred_words_title,
      l10n.achievement_solve_hundred_words_description,
    ),
    build(
      'solve_fivehundred_words',
      l10n.achievement_solve_fivehundred_words_title,
      l10n.achievement_solve_fivehundred_words_description,
    ),
    build(
      'solve_thousand_words',
      l10n.achievement_solve_thousand_words_title,
      l10n.achievement_solve_thousand_words_description,
    ),
    build(
      'learn_ten_words',
      l10n.achievement_learn_ten_words_title,
      l10n.achievement_learn_ten_words_description,
    ),
    build(
      'learn_twenty_words',
      l10n.achievement_learn_twenty_words_title,
      l10n.achievement_learn_twenty_words_description,
    ),
  ];
}
