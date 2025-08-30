import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/settings/settings_sheet.dart';
import 'package:linguess/features/sfx/sfx_button.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/providers/daily_puzzle_provider.dart';
import 'package:linguess/providers/economy_provider.dart';
import 'package:linguess/providers/ads_provider.dart';

class HomeMobile extends ConsumerStatefulWidget {
  const HomeMobile({super.key});

  @override
  ConsumerState<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends ConsumerState<HomeMobile> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          SfxIconButton(
            tooltip: l10n.adRewardTooltip,
            icon: const Icon(Icons.play_circle_fill),
            onPressed: () async {
              final ads = ref.read(adsServiceProvider);
              await ads.showRewarded(
                context,
                onReward: (reward) async {
                  final economy = ref.read(economyServiceProvider);
                  await economy.grantAdRewardGold(50); // Gold reward
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.adRewardGoldEarned(50)),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.mainMenuPlayModeSelection,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SfxElevatedButton(
              onPressed: () => context.push('/category'),
              child: Text(l10n.selectCategory),
            ),
            const SizedBox(height: 12),
            SfxElevatedButton(
              onPressed: () => context.push('/level'),
              child: Text(l10n.selectLevel),
            ),
            const SizedBox(height: 12),
            SfxElevatedButton(
              onPressed: () => handleDailyButton(context, ref),
              child: Text(l10n.dailyWord),
            ),
            const SizedBox(height: 12),
            SfxElevatedButton(
              onPressed: () => showSettingsSheet(context),
              child: Text(l10n.settings),
            ),
            const Spacer(),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Align(
                  alignment: Alignment.bottomRight,
                  child: SfxElevatedButton(
                    onPressed: () {
                      if (user == null) {
                        context.push('/login');
                      } else {
                        context.push('/profile');
                      }
                    },
                    child: Text(user == null ? l10n.login : l10n.profile),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
