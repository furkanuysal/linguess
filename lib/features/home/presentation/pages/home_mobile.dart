import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/features/admin/presentation/providers/is_admin_provider.dart';
import 'package:linguess/features/ads/presentation/widgets/confirm_reward_dialog.dart';
import 'package:linguess/features/auth/presentation/providers/user_equipped_provider.dart';
import 'package:linguess/features/auth/presentation/widgets/equipped_avatar.dart';
import 'package:linguess/features/home/presentation/widgets/home_mobile_widgets.dart';
import 'package:linguess/features/home/presentation/utils/home_menu_items.dart';
import 'package:linguess/core/sfx/sfx_button.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
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

    final user = currentUser();
    final isAdminAsync = ref.watch(isAdminProvider);

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(avatarImageProvider);
        ref.invalidate(avatarFrameProvider);
      });
    }

    final statusDot = user == null ? scheme.outline : Colors.greenAccent;
    final statusLabel = user == null ? l10n.signIn : l10n.profile;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.appTitle,
        centerTitle: true,
        actions: [
          // Rewarded Ad button
          Semantics(
            label: '${l10n.adRewardTooltip} — Ad',
            button: true,
            child: SfxIconButton(
              tooltip: '${l10n.adRewardTooltip} • Ad',
              icon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.ondemand_video_rounded,
                      color: scheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ad',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SfxIconButton(
              tooltip: statusLabel,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.surfaceContainerHighest,
                        width: 2,
                      ),
                    ),
                    child: const EquippedAvatar(
                      size: 38,
                      iconSize: 22,
                      showRingFallback: true,
                      borderWidth: 0,
                    ),
                  ),
                  // Status dot
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusDot,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (user == null) {
                  context.push('/signIn');
                } else {
                  context.push('/profile');
                }
              },
              onLongPress: () {
                final isAdmin = isAdminAsync.asData?.value ?? false;
                if (isAdmin) {
                  context.push('/admin/debug');
                }
              },
            ),
          ),
        ],
      ),

      // Body
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
                        children: getHomeMenuItems(context, ref, l10n)
                            .asMap()
                            .entries
                            .map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return MenuCardButton(
                                    width: itemWidth,
                                    icon: item.icon,
                                    label: item.label,
                                    badge: item.badge,
                                    onTap: item.onTap,
                                  )
                                  .animate(
                                    delay: (100 * index).ms,
                                  ) // Staggered delay
                                  .fadeIn(
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slideY(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 400.ms,
                                    curve: Curves.easeOut,
                                  );
                            })
                            .toList(),
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
