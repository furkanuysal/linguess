import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/home/presentation/utils/home_menu_items.dart';
import 'package:linguess/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/admin/presentation/providers/is_admin_provider.dart';

class HomeWindows extends ConsumerStatefulWidget {
  const HomeWindows({super.key});

  @override
  ConsumerState<HomeWindows> createState() => _HomeWindowsState();
}

class _HomeWindowsState extends ConsumerState<HomeWindows> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.appTitle,
        centerTitle: true,
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return IconButton(
                tooltip: user == null ? l10n.signIn : l10n.profile,
                icon: Icon(
                  user == null ? Icons.login : Icons.account_circle,
                  color: scheme.primary,
                ),
                onPressed: () {
                  if (user == null) {
                    context.push('/signIn');
                  } else {
                    context.push('/profile');
                  }
                },
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
                    onPressed: () {
                      context.push('/admin');
                    },
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
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          shrinkWrap: true,
                          children: getHomeMenuItems(context, ref, l10n)
                              .where(
                                (item) =>
                                    item.id != 'settings' && item.id != 'shop',
                              )
                              .map((item) {
                                return _buildGameModeCard(
                                  context,
                                  title: item.label,
                                  description: item.description ?? '',
                                  icon: item.icon,
                                  color: item.color ?? Colors.blue,
                                  onTap: item.onTap,
                                );
                              })
                              .toList(),
                        ),
                      ),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
