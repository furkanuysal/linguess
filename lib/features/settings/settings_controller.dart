import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

const _kRepeatLearnedWordsKey = 'repeatLearnedWords';
const _kSoundKey = 'soundEffects';

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

    return SettingsState(repeatLearnedWords: repeat, soundEffects: sound);
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
}
