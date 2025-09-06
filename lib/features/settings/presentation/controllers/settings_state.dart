class SettingsState {
  final bool repeatLearnedWords;
  final bool soundEffects;
  final bool darkMode;
  final String appLangCode;
  final String targetLangCode;

  const SettingsState({
    required this.repeatLearnedWords,
    required this.soundEffects,
    required this.darkMode,
    required this.appLangCode,
    required this.targetLangCode,
  });

  SettingsState copyWith({
    bool? repeatLearnedWords,
    bool? soundEffects,
    bool? darkMode,
    String? appLangCode,
    String? targetLangCode,
  }) {
    return SettingsState(
      repeatLearnedWords: repeatLearnedWords ?? this.repeatLearnedWords,
      soundEffects: soundEffects ?? this.soundEffects,
      darkMode: darkMode ?? this.darkMode,
      appLangCode: appLangCode ?? this.appLangCode,
      targetLangCode: targetLangCode ?? this.targetLangCode,
    );
  }
}
