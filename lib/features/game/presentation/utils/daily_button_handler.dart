import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/stats/presentation/providers/user_stats_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/core/utils/date_utils.dart';

Future<void> handleDailyButton(BuildContext context, WidgetRef ref) async {
  final user = FirebaseAuth.instance.currentUser;
  final l10n = AppLocalizations.of(context)!;

  // If user is not signed in show sign-in required message
  if (user == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.dailyWordSignInRequired),
          backgroundColor: Colors.red,
        ),
      );
    return;
  }

  final statsRepo = ref.read(statsRepositoryProvider);
  final todayId = todayIdLocal();

  // Check daily reset
  await statsRepo.checkDailyReset();

  // Has it already been solved?
  final alreadySolved = await statsRepo.hasUserSolvedDaily(todayId);
  if (alreadySolved) {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('🎯 ${l10n.dailyWordCompletedTitleAlert}'),
          content: Text(l10n.dailyWordCompletedBodyAlert),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text(l10n.okay)),
          ],
        ),
      );
    }
    return;
  }

  // If not solved, navigate to the game
  if (context.mounted) {
    context.push('/game/daily/$todayId');
  }
}
