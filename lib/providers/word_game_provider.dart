import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/models/word_model.dart';
import 'package:linguess/providers/economy_provider.dart';
import 'package:linguess/providers/user_data_provider.dart';
import 'package:linguess/providers/word_repository_provider.dart';

// --- Game Page State Class ---
class WordGameState {
  final AsyncValue<List<WordModel>> words;
  final WordModel? currentWord;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<int> hintIndices;
  final List<bool> correctIndices;
  final String currentTarget;
  final bool isShaking;

  const WordGameState({
    this.words = const AsyncValue.loading(),
    this.currentWord,
    this.controllers = const [],
    this.focusNodes = const [],
    this.hintIndices = const [],
    this.correctIndices = const [],
    this.currentTarget = '',
    this.isShaking = false,
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
    );
  }
}

// --- Notifier Class ---
final wordGameProvider = StateNotifierProvider.family
    .autoDispose<WordGameNotifier, WordGameState, WordGameParams>(
      (ref, params) => WordGameNotifier(ref, params),
    );

class WordGameParams {
  final String mode;
  final String selectedValue;

  const WordGameParams({required this.mode, required this.selectedValue});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordGameParams &&
        other.mode == mode &&
        other.selectedValue == selectedValue;
  }

  @override
  int get hashCode => mode.hashCode ^ selectedValue.hashCode;
}

class WordGameNotifier extends StateNotifier<WordGameState> {
  final Ref _ref;

  // Sınıf seviyesinde bir değişken tanımlıyoruz
  String _targetWithoutSpaces = '';

  WordGameNotifier(this._ref, WordGameParams params)
    : super(const WordGameState()) {
    _fetchWords(params.mode, params.selectedValue);
  }

  void _cleanUpResources() {
    for (var c in state.controllers) {
      c.dispose();
    }
    for (var f in state.focusNodes) {
      f.dispose();
    }
  }

  Future<void> _fetchWords(String mode, String selectedValue) async {
    final wordRepository = _ref.read(wordRepositoryProvider);
    try {
      final words = mode == 'category'
          ? await wordRepository.fetchWordsByCategory(selectedValue)
          : await wordRepository.fetchWordsByLevel(selectedValue);

      state = state.copyWith(words: AsyncValue.data(words));
      _loadRandomWord();
    } catch (e, st) {
      state = state.copyWith(words: AsyncValue.error(e, st));
    }
  }

  void _loadRandomWord() {
    state.words.whenData((words) {
      if (words.isNotEmpty) {
        final randomWord = (words.toList()..shuffle()).first;
        _initializeWord(randomWord);
      }
    });
  }

  void _initializeWord(WordModel word) {
    final currentTarget = (word.translations['en'] ?? '').toUpperCase();

    // Değişkeni burada bir kez hesaplayıp atıyoruz
    _targetWithoutSpaces = currentTarget.replaceAll(' ', '');

    _cleanUpResources();

    final controllers = List.generate(
      _targetWithoutSpaces.length,
      (_) => TextEditingController(),
    );
    final focusNodes = List.generate(
      _targetWithoutSpaces.length,
      (_) => FocusNode(),
    );
    final correctIndices = List.generate(
      _targetWithoutSpaces.length,
      (_) => false,
    );

    state = state.copyWith(
      currentWord: word,
      currentTarget: currentTarget,
      controllers: controllers,
      focusNodes: focusNodes,
      correctIndices: correctIndices,
      hintIndices: [],
    );
  }

  int logicalIndexFromVisual(int visualIndex) {
    int count = 0;
    for (int i = 0; i <= visualIndex; i++) {
      if (state.currentTarget[i] != ' ') {
        count++;
      }
    }
    return count - 1;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showSuccessDialog(BuildContext context) async {
    final economyService = _ref.read(economyServiceProvider);
    await economyService.rewardGold(state.hintIndices.length);

    final locale = Localizations.localeOf(context).languageCode;
    final correctAnswerFormatted = _capitalize(state.currentTarget);

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 ${AppLocalizations.of(context)!.correctText}!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppLocalizations.of(context)!.yourWord}: ${state.currentWord!.translations[locale] ?? '???'}',
            ),
            Text(
              '${AppLocalizations.of(context)!.correctAnswer}: $correctAnswerFormatted',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadRandomWord();
            },
            child: Text(AppLocalizations.of(context)!.nextWord),
          ),
        ],
      ),
    );
  }

  Future<void> checkAnswer(BuildContext context) async {
    // Hesaplanan değişkeni direkt kullanıyoruz
    bool isAllCorrect = true;
    final newCorrectIndices = List.of(state.correctIndices);

    for (int i = 0; i < _targetWithoutSpaces.length; i++) {
      final input = state.controllers[i].text.toUpperCase();
      if (input == _targetWithoutSpaces[i]) {
        newCorrectIndices[i] = true;
      } else {
        newCorrectIndices[i] = false;
        isAllCorrect = false;
        state.controllers[i].clear();
      }
    }

    state = state.copyWith(correctIndices: newCorrectIndices);

    if (isAllCorrect) {
      final userService = _ref.read(userServiceProvider);
      await userService.handleCorrectAnswer(state.currentTarget);
      _showSuccessDialog(context);
    } else {
      state = state.copyWith(isShaking: true);
    }
  }

  void onShakeAnimationComplete() {
    // Hesaplanan değişkeni direkt kullanıyoruz
    bool focused = false;

    for (int i = 0; i < _targetWithoutSpaces.length; i++) {
      if (!state.correctIndices[i]) {
        state.controllers[i].clear();
      }

      if (!focused && state.controllers[i].text.isEmpty) {
        state.focusNodes[i].requestFocus();
        focused = true;
      }
    }

    state = state.copyWith(isShaking: false);
  }

  void showHintLetter(BuildContext context) async {
    // Hesaplanan değişkeni direkt kullanıyoruz
    if (state.hintIndices.length >= _targetWithoutSpaces.length) return;

    final economyService = _ref.read(economyServiceProvider);
    final canUseHint = await economyService.tryUseHint();

    if (!canUseHint) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Yetersiz altın!")));
      }
      return;
    }

    final remainingIndices =
        List.generate(_targetWithoutSpaces.length, (i) => i)
            .where(
              (i) => !state.hintIndices.contains(i) && !state.correctIndices[i],
            )
            .toList();

    if (remainingIndices.isNotEmpty) {
      final rand = Random();
      final index = remainingIndices[rand.nextInt(remainingIndices.length)];

      final newHintIndices = [...state.hintIndices, index];
      final newCorrectIndices = List.of(state.correctIndices);
      newCorrectIndices[index] = true;

      state.controllers[index].text = _targetWithoutSpaces[index];

      state = state.copyWith(
        hintIndices: newHintIndices,
        correctIndices: newCorrectIndices,
      );
    }
  }

  void onTextChanged(BuildContext context, int logicalIndex, String value) {
    if (value.isNotEmpty) {
      final upper = value.toUpperCase();
      if (state.controllers[logicalIndex].text != upper) {
        state.controllers[logicalIndex].text = upper;
        state.controllers[logicalIndex].selection = TextSelection.fromPosition(
          TextPosition(offset: upper.length),
        );
      }

      for (int i = logicalIndex + 1; i < state.controllers.length; i++) {
        if (state.controllers[i].text.isEmpty && !state.correctIndices[i]) {
          state.focusNodes[i].requestFocus();
          break;
        }
      }
    }

    final allFilled = state.controllers.every((c) => c.text.isNotEmpty);
    if (allFilled) {
      checkAnswer(context);
    }
  }

  @override
  void dispose() {
    _cleanUpResources();
    super.dispose();
  }
}
