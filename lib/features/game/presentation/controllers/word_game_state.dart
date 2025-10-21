import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/data/models/word_model.dart';

class WordGameState {
  final AsyncValue<List<WordModel>> words;
  final WordModel? currentWord;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<int> hintIndices;
  final List<bool> correctIndices;
  final String currentTarget;
  final bool isShaking;
  final bool isDaily;
  final bool dailyAlreadySolved;
  final bool isLoading;
  final bool isDefinitionUsedForCurrentWord;
  final bool isExampleSentenceUsedForCurrentWord;
  final bool isExampleSentenceTargetUsedForCurrentWord;
  final bool isTimeAttack;
  final bool isTimeAttackFinished;
  final int remainingSeconds;
  final int timeAttackCorrectCount;

  const WordGameState({
    this.words = const AsyncValue.loading(),
    this.currentWord,
    this.controllers = const [],
    this.focusNodes = const [],
    this.hintIndices = const [],
    this.correctIndices = const [],
    this.currentTarget = '',
    this.isShaking = false,
    this.isDaily = false,
    this.dailyAlreadySolved = false,
    this.isLoading = false,
    this.isDefinitionUsedForCurrentWord = false,
    this.isExampleSentenceUsedForCurrentWord = false,
    this.isExampleSentenceTargetUsedForCurrentWord = false,
    this.isTimeAttack = false,
    this.isTimeAttackFinished = false,
    this.remainingSeconds = 0,
    this.timeAttackCorrectCount = 0,
  });

  WordGameState copyWith({
    AsyncValue<List<WordModel>>? words,
    WordModel? currentWord,
    List<TextEditingController>? controllers,
    List<FocusNode>? focusNodes,
    List<int>? hintIndices,
    List<bool>? correctIndices,
    String? currentTarget,
    bool? isShaking,
    bool? isDaily,
    bool? dailyAlreadySolved,
    bool? isLoading,
    bool? isDefinitionUsedForCurrentWord,
    bool? isExampleSentenceUsedForCurrentWord,
    bool? isExampleSentenceTargetUsedForCurrentWord,
    bool? isTimeAttack,
    bool? isTimeAttackFinished,
    int? remainingSeconds,
    int? timeAttackCorrectCount,
  }) {
    return WordGameState(
      words: words ?? this.words,
      currentWord: currentWord ?? this.currentWord,
      controllers: controllers ?? this.controllers,
      focusNodes: focusNodes ?? this.focusNodes,
      hintIndices: hintIndices ?? this.hintIndices,
      correctIndices: correctIndices ?? this.correctIndices,
      currentTarget: currentTarget ?? this.currentTarget,
      isShaking: isShaking ?? this.isShaking,
      isDaily: isDaily ?? this.isDaily,
      dailyAlreadySolved: dailyAlreadySolved ?? this.dailyAlreadySolved,
      isLoading: isLoading ?? this.isLoading,
      isDefinitionUsedForCurrentWord:
          isDefinitionUsedForCurrentWord ?? this.isDefinitionUsedForCurrentWord,
      isExampleSentenceUsedForCurrentWord:
          isExampleSentenceUsedForCurrentWord ??
          this.isExampleSentenceUsedForCurrentWord,
      isExampleSentenceTargetUsedForCurrentWord:
          isExampleSentenceTargetUsedForCurrentWord ??
          this.isExampleSentenceTargetUsedForCurrentWord,
      isTimeAttack: isTimeAttack ?? this.isTimeAttack,
      isTimeAttackFinished: isTimeAttackFinished ?? this.isTimeAttackFinished,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      timeAttackCorrectCount:
          timeAttackCorrectCount ?? this.timeAttackCorrectCount,
    );
  }
}

enum GameModeType {
  category,
  level,
  daily,
  combined,
  meaning,
  timeAttack,
  // future modes
}

class WordGameParams {
  final Set<GameModeType> modes;
  final Map<String, String> filters;

  const WordGameParams({required this.modes, this.filters = const {}});

  bool get isDaily => modes.contains(GameModeType.daily);
  bool get isMeaningMode => modes.contains(GameModeType.meaning);
  bool get isTimeAttackMode => modes.contains(GameModeType.timeAttack);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordGameParams &&
        const SetEquality<GameModeType>().equals(modes, other.modes) &&
        const MapEquality<String, String>().equals(filters, other.filters);
  }

  @override
  int get hashCode =>
      const SetEquality<GameModeType>().hash(modes) ^
      const MapEquality<String, String>().hash(filters);

  @override
  String toString() => 'WordGameParams(modes: $modes, filters: $filters)';
}
