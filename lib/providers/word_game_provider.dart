import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/flame/confetti_particle.dart';
import 'package:linguess/features/settings/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/models/word_model.dart';
import 'package:linguess/providers/achievements_provider.dart';
import 'package:linguess/providers/daily_puzzle_provider.dart';
import 'package:linguess/providers/economy_provider.dart';
import 'package:linguess/providers/user_data_provider.dart';
import 'package:linguess/providers/word_repository_provider.dart';

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

final wordGameProvider = StateNotifierProvider.family
    .autoDispose<WordGameNotifier, WordGameState, WordGameParams>(
      (ref, params) => WordGameNotifier(ref, params),
    );

class WordGameParams {
  final String mode; // 'category' | 'level' | 'daily'
  final String selectedValue; // categoryId | levelId | (dummy/ignored on daily)

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

class WordGameNotifier extends StateNotifier<WordGameState> {
  final Ref _ref;
  final String _mode;
  final String _selectedValue;

  String _targetWithoutSpaces = '';
  List<WordModel> _rawWords = [];

  WordGameNotifier(this._ref, WordGameParams params)
    : _mode = params.mode,
      _selectedValue = params.selectedValue,
      super(const WordGameState()) {
    _fetchWords(_mode, _selectedValue);

    if (_mode != 'daily') {
      _ref.listen(settingsControllerProvider, (prev, next) {
        _reapplyFilters();
      });
      _ref.listen(userDataProvider, (prev, next) {
        _reapplyFilters();
      });
    }
  }

  void _cleanUpResources() {
    for (var c in state.controllers) {
      c.dispose();
    }
    for (var f in state.focusNodes) {
      f.dispose();
    }
  }

  String _todayIdLocal() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _hasUserSolvedDaily(String dateId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailySolved')
        .doc(dateId)
        .get();
    return doc.exists;
  }

  Future<void> _markDailySolved(String dateId, String wordId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailySolved')
        .doc(dateId);
    await ref.set({
      'wordId': wordId,
      'solvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _fetchWords(String mode, String selectedValue) async {
    final wordRepository = _ref.read(wordRepositoryProvider);

    try {
      if (mode == 'daily') {
        final dailyRepo = _ref.read(dailyPuzzleRepositoryProvider);
        final todaysWordId = await dailyRepo.getOrCreateTodayDailyWordId();
        final word = await wordRepository.fetchWordById(todaysWordId);
        if (word == null) {
          state = state.copyWith(
            words: AsyncValue.error('Daily word not found', StackTrace.current),
          );
          return;
        }

        final dateId = _todayIdLocal();
        final already = await _hasUserSolvedDaily(dateId);

        _rawWords = [word];
        state = state.copyWith(
          words: AsyncValue.data([word]),
          isDaily: true,
          dailyAlreadySolved: already,
        );

        _initializeWord(word);

        if (already) {
          for (int i = 0; i < _targetWithoutSpaces.length; i++) {
            state.controllers[i].text = _targetWithoutSpaces[i];
          }
          state = state.copyWith(
            correctIndices: List<bool>.filled(
              _targetWithoutSpaces.length,
              true,
            ),
            hintIndices: List<int>.generate(
              _targetWithoutSpaces.length,
              (i) => i,
            ),
          );
        }
        return;
      }

      // category/level
      final words = mode == 'category'
          ? await wordRepository.fetchWordsByCategory(selectedValue)
          : await wordRepository.fetchWordsByLevel(selectedValue);

      _rawWords = words;
      await _reapplyFilters(initial: true);
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(words: AsyncValue.error(e, st));
    }
  }

  /// Filter words based on user settings and learned words
  Future<void> _reapplyFilters({bool initial = false}) async {
    if (_mode == 'daily') return;

    final settings = _ref.read(settingsControllerProvider).valueOrNull;
    final repeatLearnedWords = settings?.repeatLearnedWords ?? true;

    List<String> learnedIds = const [];
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (!repeatLearnedWords && uid != null) {
      // Fetch ids from users/{uid}/learnedWords subcollection
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('learnedWords')
          .get();
      learnedIds = snap.docs.map((d) => d.id).toList();
    }

    List<WordModel> filtered = _rawWords;
    if (!repeatLearnedWords) {
      filtered = _rawWords.where((w) => !learnedIds.contains(w.id)).toList();
      if (filtered.isEmpty) filtered = _rawWords; // fallback
    }

    filtered = (filtered.toList()..shuffle());
    state = state.copyWith(words: AsyncValue.data(filtered));

    if (initial || state.currentWord == null) {
      _loadRandomWord();
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
      if (state.currentTarget[i] != ' ') count++;
    }
    return count - 1;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showSuccessDialog(BuildContext context) async {
    final economyService = _ref.read(economyServiceProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final wordToSolve = state.currentWord!.translations[locale] ?? '???';
    final correctAnswerFormatted = _capitalize(state.currentTarget);

    await economyService.rewardGold(state.hintIndices.length);

    if (state.isDaily &&
        !state.dailyAlreadySolved &&
        state.currentWord != null) {
      await _markDailySolved(_todayIdLocal(), state.currentWord!.id);
      state = state.copyWith(dailyAlreadySolved: true);
    }

    try {
      final ach = _ref.read(achievementsServiceProvider);

      if (state.hintIndices.isEmpty) {
        // No hints used achievement
        await ach.awardIfNotEarned('solve_firstword_nohint');
      }
      if (state.isDaily) {
        // Daily word first time achievement
        await ach.awardIfNotEarned('solve_dailyword_firsttime');
      }
    } catch (_) {
      // silently ignore; if achievement can't be awarded, don't disrupt game flow
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Confetti layer
          const Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(
                child:
                    SizedBox.expand(), // Empty widget for confetti background
              ),
            ),
          ),
          // Dialog layer
          Center(
            child: AlertDialog(
              title: Text('🎉 ${AppLocalizations.of(context)!.correctText}!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.yourWord}: $wordToSolve',
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.correctAnswer}: $correctAnswerFormatted',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    if (_mode == 'daily') {
                      context.pop();
                    } else {
                      _loadRandomWord();
                    }
                  },
                  child: Text(
                    _mode == 'daily'
                        ? AppLocalizations.of(context)!.close
                        : AppLocalizations.of(context)!.nextWord,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkAnswer(BuildContext context) async {
    // If daily word is already solved, do nothing
    if (state.isDaily && state.dailyAlreadySolved) return;

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
      _showSuccessDialog(context);
      await userService.onCorrectAnswer(word: state.currentWord!);
    } else {
      state = state.copyWith(isShaking: true);
    }
  }

  void onShakeAnimationComplete() {
    if (state.isDaily && state.dailyAlreadySolved) {
      state = state.copyWith(isShaking: false);
      return;
    }

    bool focused = false;
    for (int i = 0; i < _targetWithoutSpaces.length; i++) {
      if (!state.correctIndices[i]) state.controllers[i].clear();
      if (!focused && state.controllers[i].text.isEmpty) {
        state.focusNodes[i].requestFocus();
        focused = true;
      }
    }
    state = state.copyWith(isShaking: false);
  }

  void showHintLetter(BuildContext context) async {
    if (state.isDaily && state.dailyAlreadySolved) return;
    if (state.hintIndices.length >= _targetWithoutSpaces.length) return;

    final economyService = _ref.read(economyServiceProvider);
    final canUseHint = await economyService.tryUseHint();
    if (!canUseHint) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.insufficientGold),
          ),
        );
      }
      return;
    }

    final remaining = List.generate(_targetWithoutSpaces.length, (i) => i)
        .where(
          (i) => !state.hintIndices.contains(i) && !state.correctIndices[i],
        )
        .toList();

    if (remaining.isNotEmpty) {
      final index = remaining[Random().nextInt(remaining.length)];

      final newHintIndices = [...state.hintIndices, index];
      final newCorrectIndices = List.of(state.correctIndices);
      newCorrectIndices[index] = true;

      state.controllers[index].text = _targetWithoutSpaces[index];

      state = state.copyWith(
        hintIndices: newHintIndices,
        correctIndices: newCorrectIndices,
      );

      if (state.controllers.every((c) => c.text.isNotEmpty)) {
        if (context.mounted) {
          await checkAnswer(context);
        }
      }
    }
  }

  void onTextChanged(BuildContext context, int logicalIndex, String value) {
    if (state.isDaily && state.dailyAlreadySolved) return;

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

  bool onKeyEvent(int logicalIndex, KeyEvent event) {
    if (state.isDaily && state.dailyAlreadySolved) return false;

    // Only handle when the backspace key is pressed
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      // If the current box has text, clear it and stay in the same box
      if (state.controllers[logicalIndex].text.isNotEmpty) {
        if (!state.correctIndices[logicalIndex]) {
          // Only clear boxes that are not correct
          state.controllers[logicalIndex].clear();
        }
        return true; // Consume the event
      }
      // If the current box is empty, move to the previous box and clear it
      else {
        for (int i = logicalIndex - 1; i >= 0; i--) {
          if (!state.correctIndices[i]) {
            // Only go to boxes that are not correct
            state.focusNodes[i].requestFocus();
            state.controllers[i].clear();
            break;
          }
        }
        return true; // Consume the event
      }
    }

    return false; // Do not consume the event
  }

  @override
  void dispose() {
    _cleanUpResources();
    super.dispose();
  }
}
