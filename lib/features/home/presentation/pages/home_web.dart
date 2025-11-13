import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/widgets/auth_overlay.dart';
import 'package:linguess/features/home/presentation/widgets/home_web_widgets.dart';
import 'package:linguess/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/presentation/utils/daily_button_handler.dart';
import 'package:linguess/features/admin/presentation/providers/is_admin_provider.dart';

class HomeWeb extends ConsumerStatefulWidget {
  const HomeWeb({super.key});

  @override
  ConsumerState<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends ConsumerState<HomeWeb> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ResponsiveAppBar(
        title: l10n.appTitle,
        centerTitle: true,
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                // Login icon for unauthenticated users
                return IconButton(
                  tooltip: l10n.signIn,
                  icon: Icon(Icons.login, color: scheme.primary),
                  onPressed: () => AuthOverlay.show(context),
                );
              }
              // Profile icon with menu for authenticated users
              return PopupMenuButton<String>(
                tooltip: l10n.profile,
                icon: Icon(Icons.account_circle, color: scheme.primary),
                color: scheme.surfaceContainerHigh, // Menu background
                shadowColor: scheme.shadow.withValues(alpha: 0.2),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                onSelected: (value) async {
                  if (value == 'profile') {
                    context.push('/profile');
                  } else if (value == 'signOut') {
                    await ref.read(authServiceProvider).signOut();
                    if (!context.mounted) return;
                    showSnack(context, l10n.signedOut, bg: Colors.black87);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) context.go('/');
                    });
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.profile,
                          style: TextStyle(color: scheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'signOut',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: scheme.error),
                        const SizedBox(width: 8),
                        Text(
                          l10n.signOut,
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          // Admin panel button
          Consumer(
            builder: (context, ref, _) {
              final isAdminAsync = ref.watch(isAdminProvider);
              return isAdminAsync.when(
                data: (isAdmin) {
                  if (!isAdmin) return const SizedBox.shrink();
                  return IconButton(
                    tooltip: 'Admin Panel',
                    icon: Icon(
                      Icons.admin_panel_settings,
                      color: scheme.primary,
                    ),
                    onPressed: () => context.push('/admin'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.shopTitle,
            icon: Icon(Icons.store, color: scheme.primary),
            onPressed: () => context.push('/shop'),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.settings,
            icon: Icon(Icons.settings, color: scheme.primary),
            onPressed: () => showSettingsSheet(context),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                children: [
                  Text(
                    l10n.mainMenuPlayModeSelection,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isMobileLayout = screenWidth < 500;

                        if (isMobileLayout) {
                          // Mobile Layout
                          const spacing = 16.0;

                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  WebMenuCardButton(
                                    icon: Icons.category,
                                    label: l10n.selectCategory,
                                    onTap: () => context.push('/category'),
                                  ),
                                  const SizedBox(height: spacing),
                                  WebMenuCardButton(
                                    icon: Icons.flag_rounded,
                                    label: l10n.selectLevel,
                                    onTap: () => context.push('/level'),
                                  ),
                                  const SizedBox(height: spacing),
                                  WebMenuCardButton(
                                    icon: Icons.psychology_alt_rounded,
                                    label: l10n.meaningMode,
                                    onTap: () =>
                                        context.push('/game/meaning/general'),
                                  ),
                                  const SizedBox(height: spacing),
                                  WebMenuCardButton(
                                    icon: Icons.auto_awesome_mosaic,
                                    label: l10n.customGame,
                                    onTap: () =>
                                        context.push('/combined-mode-setup'),
                                  ),
                                  const SizedBox(height: spacing),
                                  WebMenuCardButton(
                                    icon: Icons.calendar_today_rounded,
                                    label: l10n.dailyWord,
                                    badge: l10n.todayText,
                                    onTap: () =>
                                        handleDailyButton(context, ref),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Web/Desktop Layout
                        bool showDescription = screenWidth > 900;

                        double aspect = 0.95;
                        if (screenWidth < 700) {
                          aspect = 1.1;
                        } else if (screenWidth < 1000) {
                          aspect = 1.0;
                        } else if (screenWidth < 1300) {
                          aspect = 0.9;
                        } else {
                          aspect = 0.85;
                        }

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: GridView(
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 300,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    childAspectRatio: aspect,
                                  ),
                              shrinkWrap: true,
                              children: [
                                WebGameModeCard(
                                  title: l10n.selectCategory,
                                  description: showDescription
                                      ? l10n.selectCategoryDescription
                                      : '',
                                  icon: Icons.category,
                                  color: Colors.blue,
                                  onTap: () => context.push('/category'),
                                ),
                                WebGameModeCard(
                                  title: l10n.selectLevel,
                                  description: showDescription
                                      ? l10n.selectLevelDescription
                                      : '',
                                  icon: Icons.star,
                                  color: Colors.green,
                                  onTap: () => context.push('/level'),
                                ),
                                WebGameModeCard(
                                  title: l10n.dailyWord,
                                  description: showDescription
                                      ? l10n.dailyWordDescription
                                      : '',
                                  icon: Icons.today,
                                  color: Colors.orange,
                                  onTap: () => handleDailyButton(context, ref),
                                ),
                                WebGameModeCard(
                                  title: l10n.meaningMode,
                                  description: showDescription
                                      ? l10n.meaningModeDescription
                                      : '',
                                  icon: Icons.psychology_alt_rounded,
                                  color: Colors.purple,
                                  onTap: () =>
                                      context.push('/game/meaning/general'),
                                ),
                                WebGameModeCard(
                                  title: l10n.customGame,
                                  description: showDescription
                                      ? l10n.customGameDescription
                                      : '',
                                  icon: Icons.auto_awesome_mosaic,
                                  color: Colors.red,
                                  onTap: () =>
                                      context.push('/combined-mode-setup'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
