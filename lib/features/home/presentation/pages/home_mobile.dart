import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/ads/presentation/widgets/confirm_reward_dialog.dart';
import 'package:linguess/features/home/presentation/widgets/home_mobile_widgets.dart';
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.primary,
          // small shadow
          shadows: [
            Shadow(
              blurRadius: 2,
              offset: Offset(0, 1),
              color: Color(0x33000000),
            ),
          ],
        ),
        flexibleSpace: Container(
          // thin gradient at the top of the AppBar
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface.withValues(alpha: 0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
        title: Text(l10n.appTitle),
        actions: [
          // Rewarded Ad button
          Semantics(
            label: '${l10n.adRewardTooltip} — Ad',
            button: true,
            child: SfxIconButton(
              tooltip: '${l10n.adRewardTooltip} • Ad',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.ondemand_video,
                    color: scheme.primary.withValues(alpha: 0.80),
                  ),
                  // Small "Ad" badge
                  Positioned(
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
          // Profile / Sign-in AppBar action
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snap) {
              final user = snap.data;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SfxIconButton(
                  tooltip: user == null ? l10n.signIn : l10n.profile,
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: scheme.primary.withValues(alpha: 0.20),
                    child: Icon(
                      user == null ? Icons.person_outline : Icons.person,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                  onPressed: () {
                    if (user == null) {
                      context.push('/signIn');
                    } else {
                      context.push('/profile');
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeaderSubtitle(
                    title: l10n.mainMenuPlayModeSelection,
                    subtitle: l10n.mainMenuLearnNewWordsToday,
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final spacing = 16.0;
                      final cols = w >= 720 ? 3 : (w >= 420 ? 2 : 1);
                      final itemWidth = (w - spacing * (cols - 1)) / cols;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          MenuCardButton(
                            width: itemWidth,
                            icon: Icons.category,
                            label: l10n.selectCategory,
                            onTap: () => context.push('/category'),
                          ),
                          MenuCardButton(
                            width: itemWidth,
                            icon: Icons.flag_rounded,
                            label: l10n.selectLevel,
                            onTap: () => context.push('/level'),
                          ),
                          MenuCardButton(
                            width: itemWidth,
                            icon: Icons.calendar_today_rounded,
                            label: l10n.dailyWord,
                            badge: l10n.todayText,
                            onTap: () => handleDailyButton(context, ref),
                          ),
                          MenuCardButton(
                            width: itemWidth,
                            icon: Icons.settings,
                            label: l10n.settings,
                            onTap: () => showSettingsSheet(context),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
