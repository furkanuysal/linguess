import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/leveling/presentation/providers/leveling_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDebugPage extends ConsumerWidget {
  const AdminDebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(levelingRepositoryProvider);
    final xpToAward = 5;

    Future<void> addXp(int amount) async {
      await repo.addXp(amount);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminXpGivenSnackBar(amount)),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Future<void> resetLevel() async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('stats')
          .doc('leveling');

      await ref.set({
        'level': 1,
        'xp': 95,
        'totalXp': 95,
      }, SetOptions(merge: true));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminLevelResetSnackBar),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Debug'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.green,
            ),
            title: Text(l10n.adminGiveXpButtonTitle(xpToAward)),
            subtitle: Text(l10n.adminGiveXpButtonDesc(xpToAward)),
            onTap: () => addXp(xpToAward),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.restart_alt_rounded,
              color: Colors.orange,
            ),
            title: Text(l10n.adminResetLevelToOneButtonTitle),
            subtitle: Text(l10n.adminResetLevelToOneButtonDesc),
            onTap: resetLevel,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            title: Text(l10n.adminClearLastLevelCacheButtonTitle),
            subtitle: Text(l10n.adminClearLastLevelCacheButtonDesc),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final key = uid != null
                  ? 'user_${uid}_last_level'
                  : 'last_known_level';
              await prefs.remove(key);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.adminLastLevelCacheClearedSnackBar),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.redAccent,
            ),
            title: Text(l10n.adminClearAllLocalDataButtonTitle),
            subtitle: Text(l10n.adminClearAllLocalDataButtonDesc),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.adminClearAllConfirmationTitle),
                  content: Text(l10n.adminClearAllConfirmationDesc),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancelText),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.adminClearAllButtonText),
                    ),
                  ],
                ),
              );

              if (confirm != true) return; // If not confirmed, exit

              final prefs = await SharedPreferences.getInstance();
              final success = await prefs.clear();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? l10n.adminAllLocalDataClearedSnackBar
                        : l10n.adminClearAllLocalDataErrorSnackBar,
                  ),
                  backgroundColor: success ? Colors.redAccent : Colors.grey,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
