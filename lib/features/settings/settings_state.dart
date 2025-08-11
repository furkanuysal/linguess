class SettingsState {
  final bool repeatLearnedWords;
  final bool soundEffects;

  const SettingsState({
    required this.repeatLearnedWords,
    required this.soundEffects,
  });

  SettingsState copyWith({bool? repeatLearnedWords, bool? soundEffects}) {
    return SettingsState(
      repeatLearnedWords: repeatLearnedWords ?? this.repeatLearnedWords,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }
}
