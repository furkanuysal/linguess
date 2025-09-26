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
    ),
    AchievementModel(
      id: 'learn_firstword',
      title: l10n.achievement_learn_firstword_title,
      description: l10n.achievement_learn_firstword_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_dailyword_firsttime',
      title: l10n.achievement_solve_dailyword_firsttime_title,
      description: l10n.achievement_solve_dailyword_firsttime_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_firstword_nohint',
      title: l10n.achievement_solve_firstword_nohint_title,
      description: l10n.achievement_solve_firstword_nohint_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_ten_words',
      title: l10n.achievement_solve_ten_words_title,
      description: l10n.achievement_solve_ten_words_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_fifty_words',
      title: l10n.achievement_solve_fifty_words_title,
      description: l10n.achievement_solve_fifty_words_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_hundred_words',
      title: l10n.achievement_solve_hundred_words_title,
      description: l10n.achievement_solve_hundred_words_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_fivehundred_words',
      title: l10n.achievement_solve_fivehundred_words_title,
      description: l10n.achievement_solve_fivehundred_words_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'solve_thousand_words',
      title: l10n.achievement_solve_thousand_words_title,
      description: l10n.achievement_solve_thousand_words_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'used_definition_powerup_first_time',
      title: l10n.achievement_used_definition_powerup_first_time_title,
      description:
          l10n.achievement_used_definition_powerup_first_time_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'used_hint_powerup_first_time',
      title: l10n.achievement_used_hint_powerup_first_time_title,
      description: l10n.achievement_used_hint_powerup_first_time_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'used_skip_powerup_first_time',
      title: l10n.achievement_used_skip_powerup_first_time_title,
      description: l10n.achievement_used_skip_powerup_first_time_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'used_example_sentence_powerup_first_time',
      title: l10n.achievement_used_example_sentence_powerup_first_time_title,
      description:
          l10n.achievement_used_example_sentence_powerup_first_time_description,
      icon: '/empty',
    ),
    AchievementModel(
      id: 'used_example_sentence_target_powerup_first_time',
      title: l10n
          .achievement_used_example_sentence_target_powerup_first_time_title,
      description: l10n
          .achievement_used_example_sentence_target_powerup_first_time_description,
      icon: '/empty',
    ),
  ];
}
