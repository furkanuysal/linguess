import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';

List<AchievementModel> buildAchievements(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return [
    AchievementModel(
      id: 'solve_firstword',
      title: l10n.achievement_solve_firstword_title,
      description: l10n.achievement_solve_firstword_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'solve_firstword_nohint',
      title: l10n.achievement_solve_firstword_nohint_title,
      description: l10n.achievement_solve_firstword_nohint_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'solve_dailyword_first_time',
      title: l10n.achievement_solve_dailyword_first_time_title,
      description: l10n.achievement_solve_dailyword_first_time_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'learn_firstword',
      title: l10n.achievement_learn_firstword_title,
      description: l10n.achievement_learn_firstword_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'used_definition_powerup_first_time',
      title: l10n.achievement_used_definition_powerup_first_time_title,
      description:
          l10n.achievement_used_definition_powerup_first_time_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'used_hint_powerup_first_time',
      title: l10n.achievement_used_hint_powerup_first_time_title,
      description: l10n.achievement_used_hint_powerup_first_time_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'used_skip_powerup_first_time',
      title: l10n.achievement_used_skip_powerup_first_time_title,
      description: l10n.achievement_used_skip_powerup_first_time_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'used_example_sentence_powerup_first_time',
      title: l10n.achievement_used_example_sentence_powerup_first_time_title,
      description:
          l10n.achievement_used_example_sentence_powerup_first_time_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'used_example_sentence_target_powerup_first_time',
      title: l10n
          .achievement_used_example_sentence_target_powerup_first_time_title,
      description: l10n
          .achievement_used_example_sentence_target_powerup_first_time_description,
      icon: '/empty',
      hasProgress: false,
    ),
    AchievementModel(
      id: 'solve_dailyword_ten_times',
      title: l10n.achievement_solve_dailyword_ten_times_title,
      description: l10n.achievement_solve_dailyword_ten_times_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.dailySolvedTotal,
      progressTarget: 10,
    ),
    AchievementModel(
      id: 'solve_dailyword_thirty_times',
      title: l10n.achievement_solve_dailyword_thirty_times_title,
      description: l10n.achievement_solve_dailyword_thirty_times_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.dailySolvedTotal,
      progressTarget: 30,
    ),
    AchievementModel(
      id: 'solve_ten_words',
      title: l10n.achievement_solve_ten_words_title,
      description: l10n.achievement_solve_ten_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.solvedWordsTotal,
      progressTarget: 10,
    ),
    AchievementModel(
      id: 'solve_fifty_words',
      title: l10n.achievement_solve_fifty_words_title,
      description: l10n.achievement_solve_fifty_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.solvedWordsTotal,
      progressTarget: 50,
    ),
    AchievementModel(
      id: 'solve_hundred_words',
      title: l10n.achievement_solve_hundred_words_title,
      description: l10n.achievement_solve_hundred_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.solvedWordsTotal,
      progressTarget: 100,
    ),
    AchievementModel(
      id: 'solve_fivehundred_words',
      title: l10n.achievement_solve_fivehundred_words_title,
      description: l10n.achievement_solve_fivehundred_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.solvedWordsTotal,
      progressTarget: 500,
    ),
    AchievementModel(
      id: 'solve_thousand_words',
      title: l10n.achievement_solve_thousand_words_title,
      description: l10n.achievement_solve_thousand_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.solvedWordsTotal,
      progressTarget: 1000,
    ),
    AchievementModel(
      id: 'learn_ten_words',
      title: l10n.achievement_learn_ten_words_title,
      description: l10n.achievement_learn_ten_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.learnedWordsTotal,
      progressTarget: 10,
    ),
    AchievementModel(
      id: 'learn_twenty_words',
      title: l10n.achievement_learn_twenty_words_title,
      description: l10n.achievement_learn_twenty_words_description,
      icon: '/empty',
      hasProgress: true,
      progressType: AchievementProgressType.learnedWordsTotal,
      progressTarget: 20,
    ),
  ];
}
