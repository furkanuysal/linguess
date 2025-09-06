import 'package:flutter/material.dart';
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
    );
  }
}

class WordGameParams {
  final String mode; // 'category' | 'level' | 'daily'
  final String selectedValue; // categoryId | levelId | (daily’de ignore)

  const WordGameParams({required this.mode, required this.selectedValue});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordGameParams &&
          other.mode == mode &&
          other.selectedValue == selectedValue;

  @override
  int get hashCode => mode.hashCode ^ selectedValue.hashCode;
}
