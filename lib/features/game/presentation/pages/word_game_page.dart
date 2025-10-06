import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/core/utils/localized_date_format.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/economy/data/services/economy_service.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/core/sfx/sfx_service.dart';
import 'package:linguess/features/game/presentation/widgets/powerups_bar.dart';
import 'package:linguess/features/game/presentation/widgets/word_answer_board.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/auth/presentation/providers/user_data_provider.dart';
import 'package:linguess/features/game/presentation/providers/word_game_provider.dart';

class WordGamePage extends ConsumerStatefulWidget {
  final String mode;
  final String selectedValue;

  const WordGamePage({
    super.key,
    required this.selectedValue,
    required this.mode,
  });

  @override
  ConsumerState<WordGamePage> createState() => _WordGamePageState();
}

class _WordGamePageState extends ConsumerState<WordGamePage>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _goldAnimationController;
  late final Animation<double> _goldScaleAnimation;
  late final Animation<Color?> _goldColorAnimation;
  bool get isDailyMode => widget.mode == 'daily';

  WordGameParams get _params =>
      WordGameParams(mode: widget.mode, selectedValue: widget.selectedValue);

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
        ref.read(wordGameProvider(_params).notifier).onShakeAnimationComplete();
      }
    });

    _goldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _goldScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _goldAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _goldColorAnimation =
        ColorTween(
          begin: Colors.amber.shade700,
          end: Colors.red.shade600,
        ).animate(
          CurvedAnimation(
            parent: _goldAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _goldAnimationController.dispose();
    super.dispose();
  }

  void _triggerGoldAnimation() {
    _goldAnimationController.forward().then((_) {
      _goldAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProv = wordGameProvider(_params);
    final state = ref.watch(gameProv);
    final notifier = ref.read(gameProv.notifier);
    final userDataAsync = ref.watch(userDataProvider);
    final userAsync = ref.watch(firebaseUserProvider);
    final user = userAsync.value; // User? (null = not signed in)
    final settings = ref.read(settingsControllerProvider).value;
    final appLang =
        settings?.appLangCode ?? Localizations.localeOf(context).languageCode;
    final targetLang = settings?.targetLangCode ?? 'en';
    final category = ref.watch(categoryByIdProvider(widget.selectedValue));
    final titleText = category?.titleFor(appLang) ?? widget.selectedValue;

    final sfx = ref.watch(sfxProvider);

    if (state.isShaking && !_shakeController.isAnimating) {
      _shakeController.forward(from: 0);
      if (!kIsWeb) {
        sfx.wrong();
      }
    }
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: isDailyMode ? l10n.dailyWord : titleText,
        subtitle: isDailyMode ? localizedDate(context, ref) : null,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        actions: [
          AnimatedBuilder(
            animation: _goldAnimationController,
            builder: (context, child) {
              final chipColor =
                  _goldColorAnimation.value ?? Colors.amber.shade800;
              return Transform.scale(
                scale: _goldScaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.secondary),
                    boxShadow: [
                      if (_goldAnimationController.isAnimating)
                        BoxShadow(
                          color: (_goldColorAnimation.value ?? Colors.amber)
                              .withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                    ],
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monetization_on, color: chipColor, size: 18),
                      const SizedBox(width: 4),
                      if (user == null)
                        Text(
                          '0',
                          style: TextStyle(
                            color: chipColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      else
                        userDataAsync.when(
                          data: (snap) {
                            if (snap == null || !snap.exists) {
                              return const Text('0');
                            }
                            final data = snap.data() as Map<String, dynamic>;
                            final gold = (data['gold'] ?? 0).toString();
                            return Text(
                              gold,
                              style: TextStyle(
                                color: chipColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, _) => Text(
                            '?',
                            style: TextStyle(
                              color: chipColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: state.words.when(
              data: (words) {
                if (state.currentWord == null) {
                  return const Center(child: RefreshProgressIndicator());
                }
                final hint = state.currentWord!.termOf(appLang);
                bool enabled(bool cond) => cond && !state.isLoading;

                bool hasText(String? s) => s != null && s.isNotEmpty;

                final hasDefinition = hasText(
                  state.currentWord!.locales.meaningOf(appLang),
                );
                final hasExampleSentence = hasText(
                  state.currentWord!.exampleSentenceOf(appLang),
                );
                final hasExampleSentenceTarget = hasText(
                  state.currentWord!.exampleSentenceOf(targetLang),
                );

                final canShowDefinition = enabled(hasDefinition);
                final canShowExampleSentence = enabled(hasExampleSentence);
                final canShowExampleSentenceTarget = enabled(
                  hasExampleSentenceTarget,
                );
                final canSkip = enabled(
                  !isDailyMode && (state.words.value?.isNotEmpty ?? false),
                );

                int visibleCost(bool alreadyUsed, int baseCost) =>
                    alreadyUsed ? 0 : baseCost;

                final visibleDefinitionCost = visibleCost(
                  state.isDefinitionUsedForCurrentWord,
                  EconomyService.showDefinitionCost,
                );
                final visibleExampleSentenceCost = visibleCost(
                  state.isExampleSentenceUsedForCurrentWord,
                  EconomyService.showExampleSentenceCost,
                );
                final visibleExampleSentenceTargetCost = visibleCost(
                  state.isExampleSentenceTargetUsedForCurrentWord,
                  EconomyService.showExampleSentenceTargetCost,
                );

                // Fixed height for the power-ups bar
                const double barHeight = 72;

                return Stack(
                  children: [
                    Column(
                      children: [
                        // Top: PowerUps bar (with SafeArea)
                        SafeArea(
                          bottom: false,
                          child: Container(
                            height: barHeight,
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: PowerUpsBar(
                                  visibleDefinitionCost: visibleDefinitionCost,
                                  visibleExampleSentenceCost:
                                      visibleExampleSentenceCost,
                                  visibleExampleSentenceTargetCost:
                                      visibleExampleSentenceTargetCost,
                                  canRevealLetter:
                                      state.hintIndices.length <
                                          state.currentTarget
                                              .replaceAll(' ', '')
                                              .length &&
                                      !state.isLoading,
                                  canSkip: canSkip,
                                  canShowDefinition: canShowDefinition,
                                  canShowExampleSentence:
                                      canShowExampleSentence,
                                  canShowExampleSentenceTarget:
                                      canShowExampleSentenceTarget,
                                  onRevealLetter: () {
                                    _triggerGoldAnimation();
                                    notifier.showHintLetter(
                                      context,
                                      cost: EconomyService.revealLetterCost,
                                    );
                                  },
                                  onSkipToNext: () async {
                                    _triggerGoldAnimation();
                                    await notifier.skipToNextWord(
                                      context,
                                      cost: EconomyService.skipWordCost,
                                    );
                                  },
                                  onShowDefinition: () {
                                    _triggerGoldAnimation();
                                    notifier.showDefinition(
                                      context,
                                      cost: EconomyService.showDefinitionCost,
                                    );
                                  },
                                  onShowExampleSentence: () {
                                    _triggerGoldAnimation();
                                    notifier.showExampleSentence(
                                      context,
                                      cost: EconomyService
                                          .showExampleSentenceCost,
                                    );
                                  },
                                  onShowExampleSentenceTarget: () {
                                    _triggerGoldAnimation();
                                    notifier.showExampleSentenceTarget(
                                      context,
                                      cost: EconomyService
                                          .showExampleSentenceTargetCost,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 6),
                                const Spacer(flex: 2),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${l10n.yourWord}: $hint',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                            color: scheme.primary,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    AnimatedBuilder(
                                      animation: _shakeController,
                                      builder: (context, child) {
                                        final t = _shakeController.value;
                                        final dx =
                                            12 * math.sin(t * 2 * math.pi * 2);
                                        return Transform.translate(
                                          offset: Offset(dx, 0),
                                          child: child,
                                        );
                                      },
                                      child: WordAnswerBoard(
                                        text: state.currentTarget,
                                        controllers: state.controllers,
                                        focusNodes: state.focusNodes,
                                        correct: state.correctIndices,
                                        onKeyEvent: (i, e) =>
                                            notifier.onKeyEvent(i, e),
                                        onChanged: (i, v) => notifier
                                            .onTextChanged(context, i, v),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(flex: 3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // LOADING overlay
                    if (state.isLoading) ...[
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(color: Colors.transparent),
                        ),
                      ),
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.25),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
