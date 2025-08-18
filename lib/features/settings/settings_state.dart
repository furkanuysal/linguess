class SettingsState {
  final bool repeatLearnedWords;
  final bool soundEffects;
  final bool darkMode;

  const SettingsState({
    required this.repeatLearnedWords,
    required this.soundEffects,
    required this.darkMode,
  });

  SettingsState copyWith({
    bool? repeatLearnedWords,
    bool? soundEffects,
    bool? darkMode,
  }) {
    return SettingsState(
      repeatLearnedWords: repeatLearnedWords ?? this.repeatLearnedWords,
      soundEffects: soundEffects ?? this.soundEffects,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
