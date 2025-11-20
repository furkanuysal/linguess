import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/utils/date_utils.dart';
import 'package:linguess/core/utils/id_utils.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/game/data/repositories/word_repository.dart';
import 'package:linguess/features/game/presentation/providers/daily_puzzle_repository_provider.dart';
import 'package:linguess/features/game/presentation/widgets/floating_hint_card.dart';
import 'package:linguess/features/game/presentation/widgets/success_dialog.dart';
import 'package:linguess/features/game/presentation/widgets/time_attack_result_dialog.dart';
import 'package:linguess/features/leveling/presentation/providers/leveling_provider.dart';
import 'package:linguess/features/resume/data/models/resume_state.dart';
import 'package:linguess/features/resume/data/providers/resume_category_repository.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/shop/data/providers/active_boosters_provider.dart';
import 'package:linguess/features/stats/presentation/providers/hint_stats_provider.dart';
import 'package:linguess/features/stats/presentation/providers/user_stats_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/data/models/word_model.dart';
import 'package:linguess/features/achievements/presentation/providers/achievements_provider.dart';
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
  bool _isDefinitionUsedForCurrentWord = false;
  bool _isExampleSentenceUsedForCurrentWord = false;
  bool _isExampleSentenceTargetUsedForCurrentWord = false;
  bool _fallbackNotified = false;

  static const int _baseXPPerCorrect = 5;

  Timer? _timer;
  static const int _extraSecondsPerCorrect = 2;
  static const int _extraGoldPerCorrect = 2;

  @override
  WordGameState build() {
    if (!_didInit) {
      _didInit = true;

      if (!params.isDaily) {
        ref.listen(settingsControllerProvider, (prev, next) {
          _reapplyFilters();
        });
        ref.listen(userDataProvider, (prev, next) {
          _reapplyFilters();
        });
      }
      ref.onDispose(() {
        _cleanUpResources();
        _timer?.cancel();
      });

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

  Future<void> _safeResumeCall(Future<void> Function() action) async {
    if (params.modes.contains(GameModeType.timeAttack)) return;
    try {
      await action();
    } catch (e) {
      debugPrint('Resume update skipped or failed: $e');
    }
  }

  Future<List<String>> _fetchLearnedIds(
    bool repeatLearnedWords,
    String targetLang,
  ) async {
    if (repeatLearnedWords) return const [];

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const [];

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('targets')
        .doc(targetLang)
        .collection('learnedWords')
        .get();

    return snap.docs.map((d) => d.id).toList();
  }

  // Centralizes repeated-word fetching and fallback handling
  Future<(WordModel?, bool)> _fetchWordWithFallback({
    required WordRepository repo,
    required Map<String, String?> filters,
    required bool repeatLearnedWords,
    required List<String> learnedIds,
  }) async {
    WordModel? word = await repo.fetchRandomWordWithSettings(
      category: filters['category'],
      level: filters['level'],
      repeatLearnedWords: repeatLearnedWords,
      learnedIds: learnedIds,
    );

    bool fallbackUsed = false;

    if (word == null && !repeatLearnedWords && learnedIds.isNotEmpty) {
      word = await repo.fetchRandomWordWithSettings(
        category: filters['category'],
        level: filters['level'],
        repeatLearnedWords: true,
        learnedIds: const [],
      );
      fallbackUsed = true;
    }

    return (word, fallbackUsed);
  }

  Future<void> _markDailySolved(String dateId, String wordId) async {
    final statsRepo = ref.read(statsRepositoryProvider);

    // Daily reset check
    await statsRepo.checkDailyReset();

    // Update statistics (dailySolvedCounter +1, date, etc.)
    await statsRepo.incrementDailyCounter(wordId, dateId);

    // Clear daily resume (reset for the next day)
    try {
      final settings = ref.read(settingsControllerProvider).value;
      final targetLang = settings?.targetLangCode ?? 'en';
      final resumeDocId = makeResumeDocIdFromFilters(
        modes: {GameModeType.daily},
        filters: {},
      );
      final resumeKey = ResumeKey(targetLang, resumeDocId);
      final resumeRepo = ref.read(resumeRepositoryProvider(resumeKey));
      await resumeRepo!.clearAll(includeDailyId: true);
    } catch (e) {
      debugPrint('Failed to clear daily resume after solve: $e');
    }
  }

  Future<void> fetchWords(
    WordGameParams params, [
    BuildContext? context,
  ]) async {
    await _fetchWords(params, context);
  }

  Future<void> _fetchWords(
    WordGameParams params, [
    BuildContext? context,
  ]) async {
    final wordRepository = ref.read(wordRepositoryProvider);
    final settings = ref.read(settingsControllerProvider).value;
    final repeatLearnedWords = settings?.repeatLearnedWords ?? true;
    final targetLang = settings?.targetLangCode ?? 'en';
    final learnedIds = await _fetchLearnedIds(repeatLearnedWords, targetLang);
    _fallbackNotified = false;

    if (params.modes.contains(GameModeType.timeAttack)) {
      if (context!.mounted) await _startTimeAttack(context);
      return;
    }

    // Meaning mode (one word, random)
    if (params.modes.contains(GameModeType.meaning)) {
      try {
        var randomWord = await wordRepository.fetchRandomWordWithSettings(
          category: params.filters['category'],
          level: params.filters['level'],
          repeatLearnedWords: repeatLearnedWords,
          learnedIds: learnedIds,
        );

        if (randomWord == null) {
          // If repeatLearnedWords is off and no word was found, try fallback
          if (!repeatLearnedWords && learnedIds.isNotEmpty) {
            randomWord = await wordRepository.fetchRandomWordWithSettings(
              category: params.filters['category'],
              level: params.filters['level'],
              repeatLearnedWords: true,
              learnedIds: const [],
            );
          }

          // If no word is found, it means completely empty
          if (randomWord == null) {
            state = state.copyWith(words: AsyncValue.data([]));
            return;
          }
        }

        _rawWords = [randomWord];
        _hintsUsedForCurrentWord = 0;

        // meaning + category + level combination for resume docId
        final docId = makeResumeDocIdFromFilters(
          modes: params.modes,
          filters: {
            if (params.filters['category'] != null)
              'category': params.filters['category']!,
            if (params.filters['level'] != null)
              'level': params.filters['level']!,
          },
        );

        _resumeKey = ResumeKey(targetLang, docId);
        final resumeRepo = ref.read(resumeRepositoryProvider(_resumeKey!));

        final rs = await resumeRepo?.fetch();
        if (rs != null && rs.currentWordId.isNotEmpty) {
          final word = await wordRepository.fetchWordById(rs.currentWordId);
          if (word != null) {
            _initializeWord(word);
            _applyPrefillFromResume(rs);
            _hintsUsedForCurrentWord = rs.hintCountUsed;
            state = state.copyWith(words: AsyncValue.data([word]));
            return;
          }
        }

        await resumeRepo?.upsertInitial(currentWordId: randomWord.id);
        _initializeWord(randomWord);
        state = state.copyWith(words: AsyncValue.data([randomWord]));
      } catch (e, st) {
        state = state.copyWith(words: AsyncValue.error(e, st));
      }
      return;
    }

    // Daily mode
    if (params.isDaily) {
      try {
        final dailyRepo = ref.read(dailyPuzzleRepositoryProvider);
        final todaysWordId = await dailyRepo.getOrCreateTodayDailyWordId();
        final word = await wordRepository.fetchWordById(todaysWordId);

        if (word == null) {
          state = state.copyWith(
            words: AsyncValue.error('Daily word not found', StackTrace.current),
          );
          return;
        }
        final todayId = todayIdLocal();
        final statsRepo = ref.read(statsRepositoryProvider);
        final already = await statsRepo.hasUserSolvedDaily(todayId);
        _rawWords = [word];

        state = state.copyWith(
          words: AsyncValue.data([word]),
          isDaily: true,
          dailyAlreadySolved: already,
        );

        final resumeDocId = makeResumeDocIdFromFilters(
          modes: {GameModeType.daily},
          filters: {},
        );
        _resumeKey = ResumeKey(targetLang, resumeDocId);
        final resumeRepo = ref.read(resumeRepositoryProvider(_resumeKey!));

        final rs = await resumeRepo?.fetch();
        if (rs != null && rs.dailyDateId == todayId) {
          _hintsUsedForCurrentWord = rs.hintCountUsed;
          _initializeWord(word);
          _applyPrefillFromResume(rs);
          state = state.copyWith(
            isDefinitionUsedForCurrentWord: rs.isDefinitionUsed,
            isExampleSentenceUsedForCurrentWord: rs.isExampleSentenceUsed,
            isExampleSentenceTargetUsedForCurrentWord:
                rs.isExampleSentenceTargetUsed,
          );
        } else {
          await resumeRepo?.upsertInitial(
            currentWordId: word.id,
            extraFields: {'dailyDateId': todayId},
          );
          _initializeWord(word);
        }
      } catch (e, st) {
        state = state.copyWith(words: AsyncValue.error(e, st));
      }
      return;
    }

    // Category / Level / Both
    try {
      final hasCategory = params.filters.containsKey('category');
      final hasLevel = params.filters.containsKey('level');
      WordModel? randomWord;

      if (hasCategory && hasLevel) {
        randomWord = await wordRepository.fetchRandomWordWithSettings(
          category: params.filters['category']!,
          level: params.filters['level']!,
          repeatLearnedWords: repeatLearnedWords,
          learnedIds: learnedIds,
        );
      } else if (hasCategory) {
        randomWord = await wordRepository.fetchRandomWordWithSettings(
          category: params.filters['category']!,
          repeatLearnedWords: repeatLearnedWords,
          learnedIds: learnedIds,
        );
      } else if (hasLevel) {
        randomWord = await wordRepository.fetchRandomWordWithSettings(
          level: params.filters['level']!,
          repeatLearnedWords: repeatLearnedWords,
          learnedIds: learnedIds,
        );
      } else {
        state = state.copyWith(
          words: AsyncValue.error(
            'No filters provided for non-daily mode',
            StackTrace.current,
          ),
        );
        return;
      }

      if (randomWord == null) {
        // If repeatLearnedWords is off and no word was found, try fallback
        if (!repeatLearnedWords && learnedIds.isNotEmpty) {
          debugPrint(
            'No unlearned words left for this filter. Falling back to learned words.',
          );
          randomWord = await wordRepository.fetchRandomWordWithSettings(
            category: params.filters['category'],
            level: params.filters['level'],
            repeatLearnedWords: true,
            learnedIds: const [],
          );
        }

        // If no word is found, it means completely empty
        if (randomWord == null) {
          state = state.copyWith(
            words: AsyncValue.data([]), // Not an error, just an empty list
          );
          return;
        }
      }

      _rawWords = [randomWord];
      await _reapplyFilters(initial: true);
    } catch (e, st) {
      state = state.copyWith(words: AsyncValue.error(e, st));
    }
  }

  Future<void> _reapplyFilters({bool initial = false}) async {
    final settings = ref.read(settingsControllerProvider).value;
    final repeatLearnedWords = settings?.repeatLearnedWords ?? true;
    final targetLang =
        ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';

    final learnedIds = await _fetchLearnedIds(repeatLearnedWords, targetLang);

    List<WordModel> filtered = _rawWords;
    if (!repeatLearnedWords) {
      filtered = _rawWords.where((w) => !learnedIds.contains(w.id)).toList();
      if (filtered.isEmpty) filtered = _rawWords;
    }

    state = state.copyWith(words: AsyncValue.data(filtered));

    if (initial || state.currentWord == null) {
      await _resumeHandshake(filtered, targetLang);
    }
  }

  Future<void> _loadRandomWord(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(wordRepositoryProvider);
    final settings = ref.read(settingsControllerProvider).value;
    final repeatLearnedWords = settings?.repeatLearnedWords ?? true;
    final targetLang = settings?.targetLangCode ?? 'en';

    final learnedIds = await _fetchLearnedIds(repeatLearnedWords, targetLang);
    final (newWord, fallbackUsed) = await _fetchWordWithFallback(
      repo: repo,
      filters: params.filters,
      repeatLearnedWords: repeatLearnedWords,
      learnedIds: learnedIds,
    );

    if (!context.mounted) return;

    // If fallback is used, show only the first time
    if (fallbackUsed && !_fallbackNotified) {
      _fallbackNotified = true;
      callFloatingHintCard(
        context,
        l10n.fallbackInfoTitle,
        l10n.fallbackInfoMessage,
      );
    }

    if (newWord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noWordsFoundMessage),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _rawWords = [newWord];
    final docId = makeResumeDocIdFromFilters(
      modes: params.modes,
      filters: params.filters,
    );
    _resumeKey ??= ResumeKey(targetLang, docId);
    final resumeRepo = ref.read(resumeRepositoryProvider(_resumeKey!));
    await resumeRepo?.upsertInitial(currentWordId: newWord.id);

    _hintsUsedForCurrentWord = 0;
    _initializeWord(newWord);
    state = state.copyWith(words: AsyncValue.data([newWord]));
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
    _isDefinitionUsedForCurrentWord = false;
    _isExampleSentenceUsedForCurrentWord = false;
    _isExampleSentenceTargetUsedForCurrentWord = false;

    state = state.copyWith(
      currentWord: word,
      currentTarget: currentTarget,
      controllers: _controllers,
      focusNodes: _focusNodes,
      correctIndices: correctIndices,
      hintIndices: [],
      isDefinitionUsedForCurrentWord: _isDefinitionUsedForCurrentWord,
      isExampleSentenceUsedForCurrentWord: _isExampleSentenceUsedForCurrentWord,
      isExampleSentenceTargetUsedForCurrentWord:
          _isExampleSentenceTargetUsedForCurrentWord,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
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
    final applyGoldBoost = ref.read(applyGoldBoosterProvider);

    final appLang =
        ref.read(settingsControllerProvider).value?.appLangCode ??
        Localizations.localeOf(context).languageCode;

    final targetLang =
        ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';

    final wordToSolve = state.currentWord!.termOf(appLang);
    final correctAnswerFormatted = _capitalize(state.currentTarget);
    final isSignedIn = ref
        .watch(firebaseUserProvider)
        .maybeWhen(data: (u) => u != null, orElse: () => false);

    final correctTimes = await ref.read(
      userWordProgressCountProvider((
        targetLang: targetLang,
        wordId: state.currentWord!.id,
      )).future,
    );

    final baseGold = economyService.computeSolveRewardRaw(
      _hintsUsedForCurrentWord,
    );

    final goldToGive = await applyGoldBoost(baseGold);
    await economyService.addGold(goldToGive);

    // XP Reward Logic
    final statsRepo = ref.read(statsRepositoryProvider);
    final applyXpBoost = ref.read(applyXpBoosterProvider);
    final xpToGive = await applyXpBoost(_baseXPPerCorrect);
    await statsRepo.updateLastSolved(state.currentWord!.id);
    ref.read(levelingRepositoryProvider).addXp(xpToGive);

    if (state.isDaily &&
        !state.dailyAlreadySolved &&
        state.currentWord != null) {
      await _markDailySolved(todayIdLocal(), state.currentWord!.id);
      state = state.copyWith(dailyAlreadySolved: true);
    }

    try {
      final ach = ref.read(achievementsServiceProvider);
      if (state.hintIndices.isEmpty) {
        await ach.awardIfNotEarned('solve_firstword_nohint');
      }
      if (state.isDaily) {
        await ach.awardIfNotEarned('solve_dailyword_first_time');
      }
    } catch (_) {}

    if (!context.mounted) return;
    await SuccessDialog.show(
      context,
      earnedGold: goldToGive,
      earnedXp: xpToGive,
      askedWordInAppLang: wordToSolve,
      correctAnswer: correctAnswerFormatted,
      correctTimes: correctTimes,
      requiredTimes: 5,
      isDaily: params.isDaily,
      isSignedIn: isSignedIn,
      onSignInPressed: () async {
        context.push('/signIn');
      },
      onPrimaryPressed: () {
        if (params.isDaily) {
          context.pop();
        } else {
          _loadRandomWord(context);
        }
      },
    );
  }

  Future<void> checkAnswer(BuildContext context) async {
    if (kIsWeb) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

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

    final key = _resumeKey;
    final repo = (key != null) ? ref.read(resumeRepositoryProvider(key)) : null;
    if (repo != null) {
      final correctMap = <int, String>{};
      for (int i = 0; i < _targetWithoutSpaces.length; i++) {
        final up = state.controllers[i].text.toUpperCase();
        if (up == _targetWithoutSpaces[i]) correctMap[i] = up;
      }
      await _safeResumeCall(() async {
        await repo.setLettersBulk(correctMap);
      });
    }

    if (isAllCorrect) {
      if (!context.mounted) return;
      if (state.isTimeAttack) {
        await _handleTimeAttackProgress(context);
        return;
      }
      final userService = ref.read(userServiceProvider);
      final targetLang =
          ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';
      await userService.onCorrectAnswer(
        word: state.currentWord!,
        targetLang: targetLang,
      );
      if (!context.mounted) return;
      await _showSuccessDialog(context);
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

  Future<void> showLetterHint(BuildContext context, {required int cost}) async {
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

      final key = _resumeKey;
      final repo = (key != null)
          ? ref.read(resumeRepositoryProvider(key))
          : null;
      if (repo != null) {
        final ch = _targetWithoutSpaces[index];
        await _safeResumeCall(() async {
          await repo.setLetter(
            index: index,
            ch: ch,
            wordLen: _targetWithoutSpaces.length,
          );
          await repo.incrementHintUsed(1);
        });
        final ach = ref.read(achievementsServiceProvider);
        await ach.awardIfNotEarned('used_hint_powerup_first_time');
      }
      _hintsUsedForCurrentWord += 1;
      final hintStats = ref.read(hintStatsRepositoryProvider);
      await hintStats.incrementHintUsage('revealLetter');

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

    final docId = makeResumeDocIdFromFilters(
      modes: params.modes,
      filters: params.filters,
    );

    _resumeKey = ResumeKey(targetLang, docId);
    final repo = ref.read(resumeRepositoryProvider(_resumeKey!));
    if (repo == null) {
      final initialWord = pool.first;
      _hintsUsedForCurrentWord = 0;
      _initializeWord(initialWord);
      return;
    }

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
      _isDefinitionUsedForCurrentWord = rs.isDefinitionUsed;
      _isExampleSentenceUsedForCurrentWord = rs.isExampleSentenceUsed;
      _isExampleSentenceTargetUsedForCurrentWord =
          rs.isExampleSentenceTargetUsed;
      state = state.copyWith(
        isDefinitionUsedForCurrentWord: _isDefinitionUsedForCurrentWord,
        isExampleSentenceUsedForCurrentWord:
            _isExampleSentenceUsedForCurrentWord,
        isExampleSentenceTargetUsedForCurrentWord:
            _isExampleSentenceTargetUsedForCurrentWord,
      );
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

      final repo = ref.read(wordRepositoryProvider);
      final settings = ref.read(settingsControllerProvider).value;
      final repeatLearnedWords = settings?.repeatLearnedWords ?? true;
      final targetLang = settings?.targetLangCode ?? 'en';
      final learnedIds = await _fetchLearnedIds(repeatLearnedWords, targetLang);

      final currentId = state.currentWord?.id;
      WordModel? newWord;
      int attempt = 0;

      while (attempt < 4) {
        final (candidate, usedFallback) = await _fetchWordWithFallback(
          repo: repo,
          filters: params.filters,
          repeatLearnedWords: repeatLearnedWords,
          learnedIds: learnedIds,
        );

        if (!context.mounted) return; // safe context check

        if (usedFallback && !_fallbackNotified) {
          _fallbackNotified = true;
          callFloatingHintCard(
            context,
            l10n.fallbackInfoTitle,
            l10n.fallbackInfoMessage,
          );
        }

        if (candidate == null || candidate.id != currentId) {
          newWord = candidate;
          break;
        }
        attempt++;
      }

      if (newWord == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.noWordsFound)));
        }
        return;
      }

      _rawWords = [newWord];
      _hintsUsedForCurrentWord = 0;

      final docId = makeResumeDocIdFromFilters(
        modes: params.modes,
        filters: params.filters,
      );
      _resumeKey ??= ResumeKey(targetLang, docId);
      final resumeRepo = ref.read(resumeRepositoryProvider(_resumeKey!));

      if (resumeRepo != null) {
        await _safeResumeCall(() async {
          await resumeRepo.upsertInitial(currentWordId: newWord!.id);
        });
        final ach = ref.read(achievementsServiceProvider);
        await ach.awardIfNotEarned('used_skip_powerup_first_time');
      }
      final hintStats = ref.read(hintStatsRepositoryProvider);
      await hintStats.incrementHintUsage('skipWord');

      _initializeWord(newWord);
      state = state.copyWith(words: AsyncValue.data([newWord]));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> showDefinition(BuildContext context, {required int cost}) async {
    if (state.isDaily && state.dailyAlreadySolved) return;
    final word = state.currentWord;
    if (word == null) return;

    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsControllerProvider).value;
    final appLang =
        settings?.appLangCode ?? Localizations.localeOf(context).languageCode;

    // Get definition in app language
    final def = (word.locales as Map).meaningOf(appLang);

    if (def == null || def.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noDefinitionToShow)));
      }
      return;
    }

    if (state.isDefinitionUsedForCurrentWord) {
      if (context.mounted) {
        callFloatingHintCard(context, l10n.definitionHintTitle, def);
      }
      return;
    }

    // Resume check
    bool alreadyUsedInResume = false;
    final key = _resumeKey;
    final repo = (key != null) ? ref.read(resumeRepositoryProvider(key)) : null;

    if (repo != null) {
      try {
        final rs = await repo.fetch();
        if (rs != null && rs.currentWordId == word.id) {
          alreadyUsedInResume = rs.isDefinitionUsed;
        }
      } catch (_) {}
    }

    // Spend gold if not already used
    if (!alreadyUsedInResume) {
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
      if (repo != null) {
        try {
          final ach = ref.read(achievementsServiceProvider);
          await ach.awardIfNotEarned('used_definition_powerup_first_time');
          await _safeResumeCall(() async {
            await repo.markDefinitionUsed(true);
          });
        } catch (_) {}
      }

      _isDefinitionUsedForCurrentWord = true;
      state = state.copyWith(isDefinitionUsedForCurrentWord: true);
    }

    final hintStats = ref.read(hintStatsRepositoryProvider);
    await hintStats.incrementHintUsage('showDefinition');

    if (context.mounted) {
      callFloatingHintCard(context, l10n.definitionHintTitle, def);
    }
  }

  Future<void> showExampleSentence(
    BuildContext context, {
    required int cost,
  }) async {
    if (state.isDaily && state.dailyAlreadySolved) return;
    final word = state.currentWord;
    if (word == null) return;

    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsControllerProvider).value;
    final appLang =
        settings?.appLangCode ?? Localizations.localeOf(context).languageCode;

    // Get example sentence in app language
    final exSen = (word.locales as Map).exampleSentenceOf(appLang);

    if (exSen == null || exSen.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.noExampleSentenceToShow)));
      }
      return;
    }

    if (state.isExampleSentenceUsedForCurrentWord) {
      if (context.mounted) {
        callFloatingHintCard(context, l10n.exampleSentenceText, exSen);
      }
      return;
    }

    // Resume check
    bool alreadyUsedInResume = false;
    final key = _resumeKey;
    final repo = (key != null) ? ref.read(resumeRepositoryProvider(key)) : null;

    if (repo != null) {
      try {
        final rs = await repo.fetch();
        if (rs != null && rs.currentWordId == word.id) {
          alreadyUsedInResume = rs.isExampleSentenceUsed;
        }
      } catch (_) {}
    }

    // Spend gold if not already used
    if (!alreadyUsedInResume) {
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
      if (repo != null) {
        try {
          final ach = ref.read(achievementsServiceProvider);
          await ach.awardIfNotEarned(
            'used_example_sentence_powerup_first_time',
          );
          await _safeResumeCall(() async {
            await repo.markExampleSentenceUsed(true);
          });
        } catch (_) {}
      }

      _isExampleSentenceUsedForCurrentWord = true;
      state = state.copyWith(isExampleSentenceUsedForCurrentWord: true);
    }
    final hintStats = ref.read(hintStatsRepositoryProvider);
    await hintStats.incrementHintUsage('showExampleSentence');

    if (context.mounted) {
      callFloatingHintCard(context, l10n.exampleSentenceText, exSen);
    }
  }

  Future<void> showExampleSentenceTarget(
    BuildContext context, {
    required int cost,
  }) async {
    if (state.isDaily && state.dailyAlreadySolved) return;
    final word = state.currentWord;
    if (word == null) return;

    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsControllerProvider).value;
    final targetLang =
        settings?.targetLangCode ??
        Localizations.localeOf(context).languageCode;

    // Get example sentence target in app language
    final exSenTarget = (word.locales as Map).exampleSentenceOf(targetLang);

    if (exSenTarget == null || exSenTarget.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noExampleSentenceTargetToShow)),
        );
      }
      return;
    }

    if (state.isExampleSentenceTargetUsedForCurrentWord) {
      if (context.mounted) {
        callFloatingHintCard(
          context,
          l10n.exampleSentenceTargetTitle,
          exSenTarget,
        );
      }
      return;
    }

    // Resume check
    bool alreadyUsedInResume = false;
    final key = _resumeKey;
    final repo = (key != null) ? ref.read(resumeRepositoryProvider(key)) : null;

    if (repo != null) {
      try {
        final rs = await repo.fetch();
        if (rs != null && rs.currentWordId == word.id) {
          alreadyUsedInResume = rs.isExampleSentenceTargetUsed;
        }
      } catch (_) {}
    }

    // Spend gold if not already used
    if (!alreadyUsedInResume) {
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
      if (repo != null) {
        try {
          final ach = ref.read(achievementsServiceProvider);
          await ach.awardIfNotEarned(
            'used_example_sentence_target_powerup_first_time',
          );
          await _safeResumeCall(() async {
            await repo.markExampleSentenceTargetUsed(true);
          });
        } catch (_) {}
      }

      _isExampleSentenceTargetUsedForCurrentWord = true;
      state = state.copyWith(isExampleSentenceTargetUsedForCurrentWord: true);
    }
    final hintStats = ref.read(hintStatsRepositoryProvider);
    await hintStats.incrementHintUsage('showExampleSentenceTarget');

    if (context.mounted) {
      callFloatingHintCard(
        context,
        l10n.exampleSentenceTargetTitle,
        exSenTarget,
      );
    }
  }

  void callFloatingHintCard(
    BuildContext context,
    String title,
    String content,
  ) {
    final overlay = Overlay.of(context);
    final double top =
        (MediaQuery.of(context).padding.top + kToolbarHeight + 8);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => entry.remove(),
              child: const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: top,
            left: 12,
            right: 12,
            child: FloatingHintCard(
              title: title,
              content: content,
              onClose: () => entry.remove(),
            ),
          ),
        ],
      ),
    );
    overlay.insert(entry);
  }

  // Time Attack Mode Starter
  Future<void> _startTimeAttack([BuildContext? context]) async {
    final safeContext = context; // Safe context for dialogs/snackbars
    final l10n = context != null ? AppLocalizations.of(context) : null;
    final repo = ref.read(wordRepositoryProvider);

    _timer?.cancel();
    state = state.copyWith(isLoading: true);

    try {
      final words = await repo.fetchBatchForTimeAttack(
        category: params.filters['category'],
        level: params.filters['level'],
        limit: 25,
      );

      if (words.isEmpty) {
        if (safeContext != null && safeContext.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(safeContext).showSnackBar(
              SnackBar(content: Text(l10n!.insufficientWordsForTimeAttack)),
            );
          });
        }
        state = state.copyWith(isLoading: false);
        return;
      }

      _rawWords = words;
      _initializeWord(_rawWords.first);

      bool isEnded = false;

      state = state.copyWith(
        isLoading: false,
        isTimeAttack: true,
        isTimeAttackFinished: false,
        remainingSeconds: 60,
        timeAttackCorrectCount: 0,
        words: AsyncValue.data(_rawWords),
      );

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!ref.mounted) {
          timer.cancel();
          return;
        }

        if (isEnded) {
          timer.cancel();
          return;
        }

        final current = state.remainingSeconds - 1;
        state = state.copyWith(remainingSeconds: current);

        if (current <= 0 && !isEnded) {
          isEnded = true;
          timer.cancel();
          await _endTimeAttack(bonusGold: 0, context: safeContext);
          return;
        }

        // Refill words if needed
        if (state.timeAttackCorrectCount > 0 &&
            state.timeAttackCorrectCount % 15 == 0 &&
            _rawWords.length - state.timeAttackCorrectCount < 5) {
          final more = await repo.fetchBatchForTimeAttack(
            category: params.filters['category'],
            level: params.filters['level'],
            limit: 15,
            excludeIds: _rawWords.map((w) => w.id).toList(),
          );
          if (more.isNotEmpty) {
            _rawWords.addAll(more);
          }
        }
      });
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _endTimeAttack({
    required int bonusGold,
    BuildContext? context,
  }) async {
    final economy = ref.read(economyServiceProvider);
    final correctCount = state.timeAttackCorrectCount;
    final hasSolved = correctCount > 0;

    // Calculate rewards
    final consolationReward = hasSolved ? 0 : 2;
    final earlyCompletionBonus = bonusGold;
    final totalBonus = consolationReward + earlyCompletionBonus;

    if (totalBonus > 0) {
      await economy.addGold(totalBonus);
    }

    _timer?.cancel();
    _timer = null;

    state = state.copyWith(
      isTimeAttack: false,
      isTimeAttackFinished: true,
      remainingSeconds: 0,
    );

    if (context != null && context.mounted) {
      final totalGold = correctCount * _extraGoldPerCorrect;
      final statsRepo = ref.read(statsRepositoryProvider);
      await statsRepo.updateTimeAttackHighScore(correctCount);

      // Check sign-in status
      final isSignedIn = ref
          .watch(firebaseUserProvider)
          .maybeWhen(data: (u) => u != null, orElse: () => false);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          await TimeAttackResultDialog.show(
            context,
            correctCount: correctCount,
            totalGoldEarned: totalGold,
            onRestart: () {
              resetTimeAttack();
              fetchWords(params, context);
            },
            earlyCompletionBonus: earlyCompletionBonus,
            consolationReward: consolationReward,
            noWordSolved: !hasSolved,
            isSignedIn: isSignedIn,
            onSignInPressed: () {
              context.push('/signIn');
            },
          );
        }
      });
    } else {
      debugPrint(
        "TimeAttackResultDialog could not be shown: context null/unmounted",
      );
    }
  }

  // Time Attack Mode Progress Handler
  Future<void> _handleTimeAttackProgress(BuildContext context) async {
    if (state.currentWord == null) return;

    final repo = ref.read(wordRepositoryProvider);
    final economy = ref.read(economyServiceProvider);
    final statsRepo = ref.read(statsRepositoryProvider);
    final userService = ref.read(userServiceProvider);
    final targetLang =
        ref.read(settingsControllerProvider).value?.targetLangCode ?? 'en';
    final ctx = context;

    // Increase correct count and add time
    final newCorrectCount = state.timeAttackCorrectCount + 1;
    final newRemaining = state.remainingSeconds + _extraSecondsPerCorrect;

    // Run all async updates in parallel for performance
    await Future.wait([
      economy.addGold(_extraGoldPerCorrect),
      statsRepo.updateLastSolved(state.currentWord!.id),
      ref.read(levelingRepositoryProvider).addXp(3),
      userService.onCorrectAnswer(
        word: state.currentWord!,
        targetLang: targetLang,
      ),
    ]);

    // Move to next word
    final currentIndex = _rawWords.indexWhere(
      (w) => w.id == state.currentWord!.id,
    );
    final nextIndex = currentIndex + 1;

    // If nextIndex is out of bounds → refill or end
    if (nextIndex >= _rawWords.length) {
      final more = await repo.fetchBatchForTimeAttack(
        category: params.filters['category'],
        level: params.filters['level'],
        limit: 15,
        excludeIds: _rawWords.map((w) => w.id).toList(),
      );

      if (more.isNotEmpty) {
        _rawWords.addAll(more);
      } else {
        if (ctx.mounted) {
          await _endTimeAttack(
            context: ctx,
            bonusGold: state.remainingSeconds ~/ 2,
          );
        }
        return;
      }
    }

    // Move to next word
    _initializeWord(_rawWords[nextIndex]);
    state = state.copyWith(
      timeAttackCorrectCount: newCorrectCount,
      remainingSeconds: newRemaining,
    );
  }

  void resetTimeAttack() {
    // Clean up resources and timer
    _timer?.cancel();
    _timer = null;

    _cleanUpResources();
    _rawWords.clear();

    // Allow re-initialization
    _didInit = false;

    // Reset state
    state = const WordGameState();
  }
}
