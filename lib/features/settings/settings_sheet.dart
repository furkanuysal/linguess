import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'settings_controller.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
        ),
        data: (settings) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.settings,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.settingsLearnedWords),
              value: settings.repeatLearnedWords,
              onChanged: (val) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setRepeatLearnedWords(val);
              },
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.settingsSoundEffects),
              value: settings.soundEffects,
              onChanged: (val) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setSoundEffects(val);
              },
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.settingsDarkMode),
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
