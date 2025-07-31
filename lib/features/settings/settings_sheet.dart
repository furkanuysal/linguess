import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _repeatLearnedWords = true;
  bool _soundEffects = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _repeatLearnedWords = prefs.getBool('repeatLearnedWords') ?? true;
      _soundEffects = prefs.getBool('soundEffects') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)!.settingsLearnedWords,
                  ),
                  value: _repeatLearnedWords,
                  onChanged: (val) {
                    setState(() => _repeatLearnedWords = val);
                    _saveSetting('repeatLearnedWords', val);
                  },
                ),

                SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)!.settingsSoundEffects,
                  ),
                  value: _soundEffects,
                  onChanged: (val) {
                    setState(() => _soundEffects = val);
                    _saveSetting('soundEffects', val);
                  },
                ),
              ],
            ),
    );
  }
}

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const SettingsSheet(),
  );
}
