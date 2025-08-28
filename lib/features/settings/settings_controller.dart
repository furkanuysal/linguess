import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

const _kRepeatLearnedWordsKey = 'repeatLearnedWords';
const _kSoundKey = 'soundEffects';
const _kDarkModeKey = 'darkMode';
const _kAppLangKey = 'appLangCode';
const _kTargetLangKey = 'targetLangCode';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<SettingsState> {
  late SharedPreferences _prefs;

  @override
  Future<SettingsState> build() async {
    _prefs = await SharedPreferences.getInstance();

    final repeat = _prefs.getBool(_kRepeatLearnedWordsKey) ?? true;
    final sound = _prefs.getBool(_kSoundKey) ?? false;
    final darkMode = _prefs.getBool(_kDarkModeKey) ?? false;
    final appLangCode = _prefs.getString(_kAppLangKey) ?? 'tr';
    final targetLangCode = _prefs.getString(_kTargetLangKey) ?? 'en';

    return SettingsState(
      repeatLearnedWords: repeat,
      soundEffects: sound,
      darkMode: darkMode,
      appLangCode: appLangCode,
      targetLangCode: targetLangCode,
    );
  }

  Future<void> setRepeatLearnedWords(bool value) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(repeatLearnedWords: value));
    await _prefs.setBool(_kRepeatLearnedWordsKey, value);
  }

  Future<void> setSoundEffects(bool value) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(soundEffects: value));
    await _prefs.setBool(_kSoundKey, value);
  }

  Future<void> setDarkMode(bool value) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(darkMode: value));
    await _prefs.setBool(_kDarkModeKey, value);
  }

  Future<void> setAppLangCode(String value) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(appLangCode: value));
    await _prefs.setString(_kAppLangKey, value);
  }

  Future<void> setTargetLangCode(String value) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(targetLangCode: value));
    await _prefs.setString(_kTargetLangKey, value);
  }
}
