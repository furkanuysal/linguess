import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/effects/confetti_particle.dart';
import 'package:linguess/core/utils/id_utils.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/resume/data/models/resume_state.dart';
import 'package:linguess/features/resume/data/providers/resume_category_repository.dart';
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
  ResumeKey? _resumeKey;

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];

  String _targetWithoutSpaces = '';
  List<WordModel> _rawWords = [];
  bool _didInit =
      false; // to prevent double initialization if build is called again

  int _hintsUsedForCurrentWord = 0;

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

      return const WordGameState(); // initial setup
    }

    // If build is called again, preserve the current state
    return state;
  }

  void _cleanUpResources() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _controllers = [];
    _focusNodes = [];
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
      await _resumeHandshake(filtered, targetLang);
    }
  }

  void _loadRandomWord() async {
    state.words.whenData((words) async {
      if (words.isNotEmpty) {
        final randomWord = (words.toList()..shuffle()).first;
        final key = _resumeKey;
        if (key != null) {
          await ref
              .read(resumeRepositoryProvider(key))
              .setCurrentWord(randomWord.id);
          _hintsUsedForCurrentWord = 0;
        }
        _initializeWord(randomWord);
      }
    });
  }

  void _initializeWord(WordModel word) {
    // Get target language from settings
    final targetLang =
        ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';

    String pickTarget(WordModel w) {
      final t = w.locales as Map<String, dynamic>;

      if (t.termOf(targetLang).isNotEmpty) return t.termOf(targetLang);
      if (t.termOf('en').isNotEmpty) return t.termOf('en');

      final firstNonEmpty = t.values.firstWhere(
        (v) => (v['term']?.trim() ?? '').isNotEmpty,
        orElse: () => {'term': ''},
      );
      return (firstNonEmpty['term'] ?? '').toString().trim();
    }

    final currentTarget = pickTarget(word).toUpperCase();
    _targetWithoutSpaces = currentTarget.replaceAll(' ', '');

    _cleanUpResources();

    _controllers = List.generate(
      _targetWithoutSpaces.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      _targetWithoutSpaces.length,
      (_) => FocusNode(),
    );
    final correctIndices = List<bool>.filled(
      _targetWithoutSpaces.length,
      false,
    );

    state = state.copyWith(
      currentWord: word,
      currentTarget: currentTarget,
      controllers: _controllers,
      focusNodes: _focusNodes,
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

    final wordToSolve = state.currentWord!.pickDisplayTerm(appLang);
    final correctAnswerFormatted = _capitalize(state.currentTarget);

    await economyService.rewardGold(_hintsUsedForCurrentWord);

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

    if (_resumeKey != null) {
      final repo = ref.read(resumeRepositoryProvider(_resumeKey!));
      final correctMap = <int, String>{};
      for (int i = 0; i < _targetWithoutSpaces.length; i++) {
        final up = state.controllers[i].text.toUpperCase();
        if (up == _targetWithoutSpaces[i]) correctMap[i] = up;
      }
      await repo.setLettersBulk(correctMap);
    }

    if (isAllCorrect) {
      final userService = ref.read(userServiceProvider);
      final targetLang =
          ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';
      if (!context.mounted) return;
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

  Future<void> showHintLetter(BuildContext context, {required int cost}) async {
    if (state.isDaily && state.dailyAlreadySolved) return;
    if (state.hintIndices.length >= _targetWithoutSpaces.length) return;

    final economyService = ref.read(economyServiceProvider);
    final canUseHint = await economyService.trySpendGold(cost);
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

      final repoKey = _resumeKey;
      if (repoKey != null) {
        final repo = ref.read(resumeRepositoryProvider(repoKey));
        final ch = _targetWithoutSpaces[index];
        await repo.setLetter(
          index: index,
          ch: ch,
          wordLen: _targetWithoutSpaces.length,
        );
        final ach = ref.read(achievementsServiceProvider);
        await ach.awardIfNotEarned('used_hint_powerup_first_time');
        await repo.incrementHintUsed(1);
      }
      _hintsUsedForCurrentWord += 1;

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

  Future<void> _resumeHandshake(List<WordModel> pool, String targetLang) async {
    if (pool.isEmpty) return;

    final docId = makeResumeDocId(
      mode: params.mode,
      selectedValue: params.selectedValue,
    );

    _resumeKey = ResumeKey(targetLang, docId);
    final repo = ref.read(resumeRepositoryProvider(_resumeKey!));

    // Candidate initial word (based on current chance)
    final initialWord = pool.first;

    final rs = await repo.fetch();

    String effectiveWordId;
    if (rs == null || (rs.currentWordId.isEmpty)) {
      // No document or currentWordId is empty → start with a new selection
      effectiveWordId = initialWord.id;
      await repo.upsertInitial(currentWordId: effectiveWordId);
    } else {
      // Document exists and currentWordId is set → ALWAYS use it (even if there is no progress)
      effectiveWordId = rs.currentWordId;
    }

    // Load the word
    final wordRepo = ref.read(wordRepositoryProvider);
    final word = (effectiveWordId == initialWord.id)
        ? initialWord
        : (await wordRepo.fetchWordById(effectiveWordId)) ?? initialWord;

    if (rs != null && rs.currentWordId == effectiveWordId) {
      _hintsUsedForCurrentWord = rs.hintCountUsed; // inherit
    } else {
      _hintsUsedForCurrentWord = 0; // Clean for new word
    }
    _initializeWord(word);

    // Prefill (if the doc holds the same word, apply it)
    if (rs != null && rs.currentWordId == word.id) {
      _applyPrefillFromResume(rs);
    }
  }

  void _applyPrefillFromResume(ResumeState rs) {
    // rs.userFilled: { index : "A" }  → fill controllers
    for (final e in rs.userFilled.entries) {
      final i = e.key;
      if (i >= 0 && i < state.controllers.length) {
        final up = e.value.toUpperCase();
        state.controllers[i].text = up;
      }
    }
    // Mark correct ones as green/locked
    final newCorrect = List<bool>.from(state.correctIndices);
    for (int i = 0; i < state.controllers.length; i++) {
      if (i < _targetWithoutSpaces.length &&
          state.controllers[i].text.toUpperCase() == _targetWithoutSpaces[i]) {
        newCorrect[i] = true;
      }
    }
    state = state.copyWith(correctIndices: newCorrect);
  }

  Future<void> skipToNextWord(BuildContext context, {required int cost}) async {
    final l10n = AppLocalizations.of(context)!;
    if (state.isDaily) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.thisPowerUpNotAllowedInDaily)),
        );
      }
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final economy = ref.read(economyServiceProvider);
      final ok = await economy.trySpendGold(cost);
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.insufficientGold)));
        }
        return;
      }

      final words = state.words.value ?? const <WordModel>[];
      if (words.isEmpty) return;

      final currentId = state.currentWord?.id;
      final pool = words.where((w) => w.id != currentId).toList();
      final candidates = pool.isNotEmpty ? pool : words
        ..shuffle();
      final nextWord = candidates.first;

      _hintsUsedForCurrentWord = 0;

      final key = _resumeKey;
      if (key != null) {
        final repo = ref.read(resumeRepositoryProvider(key));
        await repo.setCurrentWord(nextWord.id);
        await repo.upsertInitial(currentWordId: nextWord.id);
      }

      _initializeWord(nextWord);
    } finally {
      final ach = ref.read(achievementsServiceProvider);
      await ach.awardIfNotEarned('used_skip_powerup_first_time');
      state = state.copyWith(isLoading: false);
    }
  }
}
