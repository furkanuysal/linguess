import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/ads/presentation/widgets/confirm_reward_dialog.dart';
import 'package:linguess/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:linguess/core/sfx/sfx_button.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/presentation/providers/daily_puzzle_provider.dart';
import 'package:linguess/features/economy/presentation/providers/economy_provider.dart';
import 'package:linguess/features/ads/presentation/providers/ads_provider.dart';

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
          Semantics(
            // Indicate that this is an ad for accessibility
            label: '${l10n.adRewardTooltip} — Ad',
            button: true,
            child: SfxIconButton(
              tooltip: '${l10n.adRewardTooltip} • Ad',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.ondemand_video),
                  Positioned(
                    // small "Ad" label at the top right corner
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                final confirmed = await confirmRewardAd(
                  context,
                  title: l10n.adRewardConfirmTitle,
                  message: l10n.adRewardConfirmBody(50),
                  cancelText: l10n.cancelText,
                  confirmText: l10n.watchAdText,
                );
                if (!confirmed || !context.mounted) return;
                final ads = ref.read(adsServiceProvider);
                await ads.showRewardedInterstitialAd(
                  context,
                  onReward: (amount, type) async {
                    // amount => AdsService.rewardAmount (50), type => 'gold'
                    await ref
                        .read(economyServiceProvider)
                        .grantAdRewardGold(amount);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.adRewardGoldEarned(amount)),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
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
