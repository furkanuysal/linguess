import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/auth/presentation/helpers/auth_snack.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/auth/presentation/widgets/auth_overlay.dart';
import 'package:linguess/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/presentation/providers/daily_puzzle_provider.dart';
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

          // admin panel button
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

                  // Responsive grid
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;

                        // Show/hide description based on width
                        bool showDescription = width > 900;

                        // Set childAspectRatio based on width
                        double aspect = 0.95;
                        if (width < 700) {
                          aspect = 1.1;
                        } else if (width < 1000) {
                          aspect = 1.0;
                        } else if (width < 1300) {
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
                                _buildGameModeCard(
                                  context,
                                  title: l10n.selectCategory,
                                  description: showDescription
                                      ? l10n.selectCategoryDescription
                                      : '',
                                  icon: Icons.category,
                                  color: Colors.blue,
                                  onTap: () => context.push('/category'),
                                ),
                                _buildGameModeCard(
                                  context,
                                  title: l10n.selectLevel,
                                  description: showDescription
                                      ? l10n.selectLevelDescription
                                      : '',
                                  icon: Icons.star,
                                  color: Colors.green,
                                  onTap: () => context.push('/level'),
                                ),
                                _buildGameModeCard(
                                  context,
                                  title: l10n.dailyWord,
                                  description: showDescription
                                      ? l10n.dailyWordDescription
                                      : '',
                                  icon: Icons.today,
                                  color: Colors.orange,
                                  onTap: () => handleDailyButton(context, ref),
                                ),
                                _buildGameModeCard(
                                  context,
                                  title: l10n.meaningMode,
                                  description: showDescription
                                      ? l10n.meaningModeDescription
                                      : '',
                                  icon: Icons.psychology_alt_rounded,
                                  color: Colors.purple,
                                  onTap: () =>
                                      context.push('/game/meaning/general'),
                                ),
                                _buildGameModeCard(
                                  context,
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

  Widget _buildGameModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    // Reduce font sizes on narrow screens
    final bool isNarrow = width < 600;
    final double titleFont = isNarrow ? 16 : 18;
    final double descFont = isNarrow ? 13 : 14;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 180,
          ), // Minimum height for better appearance
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [scheme.surface, scheme.surfaceContainerHigh],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 38, color: color),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: descFont,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    maxLines: isNarrow ? 2 : 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
