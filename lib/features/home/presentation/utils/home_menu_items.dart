import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/game/presentation/utils/daily_button_handler.dart';
import 'package:linguess/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class HomeMenuItem {
  final String id;
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;
  final String? badge;
  final Color? color;

  const HomeMenuItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.description,
    this.badge,
    this.color,
  });
}

List<HomeMenuItem> getHomeMenuItems(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  return [
    HomeMenuItem(
      id: 'category',
      icon: Icons.category,
      label: l10n.selectCategory,
      description: l10n.selectCategoryDescription,
      color: Colors.blue,
      onTap: () => context.push('/category'),
    ),
    HomeMenuItem(
      id: 'level',
      icon: Icons.flag_rounded,
      label: l10n.selectLevel,
      description: l10n.selectLevelDescription,
      color: Colors.green,
      onTap: () => context.push('/level'),
    ),
    HomeMenuItem(
      id: 'meaning',
      icon: Icons.psychology_alt_rounded,
      label: l10n.meaningMode,
      description: l10n.meaningModeDescription,
      color: Colors.purple,
      onTap: () => context.push('/game/meaning/general'),
    ),
    HomeMenuItem(
      id: 'custom',
      icon: Icons.auto_awesome_mosaic,
      label: l10n.customGame,
      description: l10n.customGameDescription,
      color: Colors.red,
      onTap: () => context.push('/combined-mode-setup'),
    ),
    HomeMenuItem(
      id: 'daily',
      icon: Icons.calendar_today_rounded,
      label: l10n.dailyWord,
      description: l10n.dailyWordDescription,
      badge: l10n.todayText,
      color: Colors.orange,
      onTap: () => handleDailyButton(context, ref),
    ),
    HomeMenuItem(
      id: 'shop',
      icon: Icons.store_rounded,
      label: l10n.shopTitle,
      onTap: () => context.push('/shop'),
    ),
    HomeMenuItem(
      id: 'leaderboard',
      icon: Icons.leaderboard,
      label: l10n.leaderboardTitle,
      onTap: () => context.push('/leaderboard'),
    ),
    HomeMenuItem(
      id: 'settings',
      icon: Icons.settings,
      label: l10n.settings,
      onTap: () => showSettingsSheet(context),
    ),
  ];
}
