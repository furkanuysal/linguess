import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'settings_controller.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  // Generate items, disabling the language selected in the other dropdown
  List<DropdownMenuItem<String>> _buildLangItems(
    List<Map<String, String>> langs, {
    required String disabledCode,
  }) {
    return langs.map((e) {
      final code = e['code']!;
      final label = e['label']!;
      final isDisabled = code == disabledCode;
      return DropdownMenuItem<String>(
        value: code,
        enabled: !isDisabled,
        child: Opacity(opacity: isDisabled ? 0.5 : 1.0, child: Text(label)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    const appLangs = [
      {'code': 'tr', 'label': 'Türkçe'},
      {'code': 'en', 'label': 'English'},
      {'code': 'es', 'label': 'Español'},
      {'code': 'de', 'label': 'Deutsch'},
    ];

    const targetLangs = [
      {'code': 'tr', 'label': 'Türkçe'},
      {'code': 'en', 'label': 'English'},
      {'code': 'es', 'label': 'Español'},
      {'code': 'de', 'label': 'Deutsch'},
    ];

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (settings) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ),
            Text(
              l10n.settings,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                // App Language
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.appLanguage,
                      border: const OutlineInputBorder(),
                    ),
                    value: settings.appLangCode,
                    items: _buildLangItems(
                      appLangs,
                      disabledCode: settings.targetLangCode,
                    ),
                    onChanged: (val) {
                      if (val == null) return;
                      if (val == settings.targetLangCode) return;
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setAppLangCode(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Swap button
                SizedBox(
                  height: 48,
                  width: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () async {
                      final app = settings.appLangCode;
                      final target = settings.targetLangCode;
                      if (app == target) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.errorOccurred)),
                        );
                        return;
                      }
                      final notifier = ref.read(
                        settingsControllerProvider.notifier,
                      );
                      // first set target to app, then app to target
                      await notifier.setAppLangCode(target);
                      await notifier.setTargetLangCode(app);
                    },
                    child: const Icon(Icons.swap_horiz),
                  ),
                ),
                const SizedBox(width: 8),
                // Target Language
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.targetLanguage,
                      border: const OutlineInputBorder(),
                    ),
                    value: settings.targetLangCode,
                    items: _buildLangItems(
                      targetLangs,
                      disabledCode: settings.appLangCode,
                    ),
                    onChanged: (val) {
                      if (val == null) return;
                      if (val == settings.appLangCode) return;
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setTargetLangCode(val);
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SwitchListTile(
              title: Text(l10n.settingsLearnedWords),
              value: settings.repeatLearnedWords,
              onChanged: (val) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setRepeatLearnedWords(val);
              },
            ),
            SwitchListTile(
              title: Text(l10n.settingsSoundEffects),
              value: settings.soundEffects,
              onChanged: (val) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setSoundEffects(val);
              },
            ),
            SwitchListTile(
              title: Text(l10n.settingsDarkMode),
              value: settings.darkMode,
              onChanged: (val) {
                ref.read(settingsControllerProvider.notifier).setDarkMode(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const SettingsSheet(),
  );
}
