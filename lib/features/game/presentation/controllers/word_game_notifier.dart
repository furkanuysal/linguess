import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/effects/confetti_particle.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/data/models/word_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
import 'package:linguess/features/game/presentation/providers/daily_puzzle_provider.dart';
import 'package:linguess/features/economy/presentation/providers/economy_provider.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';

class WordGameNotifier extends Notifier<WordGameState> {
  WordGameNotifier(this.params);
  final WordGameParams params;

  String _targetWithoutSpaces = '';
  List<WordModel> _rawWords = [];
  bool _didInit = false; // build yeniden çağrılırsa iki kez init olmaması için

  @override
  WordGameState build() {
    if (!_didInit) {
      _didInit = true;

      if (params.mode != 'daily') {
        ref.listen(settingsControllerProvider, (prev, next) {
          _reapplyFilters();
        });
        ref.listen(userDataProvider, (prev, next) {
          _reapplyFilters();
        });
      }

      _fetchWords(params.mode, params.selectedValue);
      ref.onDispose(_cleanUpResources);

      return const WordGameState(); // ilk kurulum
    }

    // build tekrar çağrılırsa mevcut state'i koru
    return state;
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
    final refDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailySolved')
        .doc(dateId);
    await refDoc.set({
      'wordId': wordId,
      'solvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _fetchWords(String mode, String selectedValue) async {
    final wordRepository = ref.read(wordRepositoryProvider);

    try {
      if (mode == 'daily') {
        final dailyRepo = ref.read(dailyPuzzleRepositoryProvider);
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
      state = state.copyWith(words: AsyncValue.error(e, st));
    }
  }

  Future<void> _reapplyFilters({bool initial = false}) async {
    if (params.mode == 'daily') return;

    // Riverpod 3: AsyncValue.valueOrNull yerine .value kullan
    final settings = ref.read(settingsControllerProvider).value;
    final repeatLearnedWords = settings?.repeatLearnedWords ?? true;
    final targetLang =
        ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';

    List<String> learnedIds = const [];
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (!repeatLearnedWords && uid != null) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('targets')
          .doc(targetLang)
          .collection('learnedWords')
          .get();
      learnedIds = snap.docs.map((d) => d.id).toList();
    }

    List<WordModel> filtered = _rawWords;
    if (!repeatLearnedWords) {
      filtered = _rawWords.where((w) => !learnedIds.contains(w.id)).toList();
      if (filtered.isEmpty) filtered = _rawWords;
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
    // Get target language from settings
    final targetLang =
        ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';

    String pickTarget(WordModel w) {
      final Map<String, String> t = w.translations;
      final fromTarget = t[targetLang];
      final fromEn = t['en'];
      final fromAny = t.isNotEmpty ? t.values.first : '';
      return (fromTarget ?? fromEn ?? fromAny);
    }

    final currentTarget = pickTarget(word).toUpperCase();
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

  Future<void> _showSuccessDialog(BuildContext context) async {
    final economyService = ref.read(economyServiceProvider);

    final appLang =
        ref.read(settingsControllerProvider).value?.appLangCode ??
        Localizations.localeOf(context).languageCode;

    final wordToSolve = state.currentWord!.translations[appLang] ?? '???';
    final correctAnswerFormatted = _capitalize(state.currentTarget);

    await economyService.rewardGold(state.hintIndices.length);

    if (state.isDaily &&
        !state.dailyAlreadySolved &&
        state.currentWord != null) {
      await _markDailySolved(_todayIdLocal(), state.currentWord!.id);
      state = state.copyWith(dailyAlreadySolved: true);
    }

    try {
      final ach = ref.read(achievementsServiceProvider);
      if (state.hintIndices.isEmpty) {
        await ach.awardIfNotEarned('solve_firstword_nohint');
      }
      if (state.isDaily) {
        await ach.awardIfNotEarned('solve_dailyword_firsttime');
      }
    } catch (_) {}

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(child: SizedBox.expand()),
            ),
          ),
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
                    if (params.mode == 'daily') {
                      context.pop();
                    } else {
                      _loadRandomWord();
                    }
                  },
                  child: Text(
                    params.mode == 'daily'
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
      final userService = ref.read(userServiceProvider);
      final targetLang =
          ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';
      await _showSuccessDialog(context);
      await userService.onCorrectAnswer(
        word: state.currentWord!,
        targetLang: targetLang,
      );
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

  Future<void> showHintLetter(BuildContext context) async {
    if (state.isDaily && state.dailyAlreadySolved) return;
    if (state.hintIndices.length >= _targetWithoutSpaces.length) return;

    final economyService = ref.read(economyServiceProvider);
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
      final newCorrectIndices = List.of(state.correctIndices)..[index] = true;

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

    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (state.controllers[logicalIndex].text.isNotEmpty) {
        if (!state.correctIndices[logicalIndex]) {
          state.controllers[logicalIndex].clear();
        }
        return true;
      } else {
        for (int i = logicalIndex - 1; i >= 0; i--) {
          if (!state.correctIndices[i]) {
            state.focusNodes[i].requestFocus();
            state.controllers[i].clear();
            break;
          }
        }
        return true;
      }
    }
    return false;
  }
}
