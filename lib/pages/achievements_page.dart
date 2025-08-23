import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievements)),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
