import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/models/achievement_model.dart';

List<AchievementModel> buildAchievements(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return [
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
  ];
}
