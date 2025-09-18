import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/auth/presentation/providers/auth_provider.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/core/sfx/sfx_service.dart';
import 'package:linguess/features/game/presentation/widgets/powerups_bar.dart';
import 'package:linguess/features/game/presentation/widgets/word_answer_board.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
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
  late final Animation<double> _shakeAnimation;
  late final AnimationController _goldAnimationController;
  late final Animation<double> _goldScaleAnimation;
  late final Animation<Color?> _goldColorAnimation;
  late final WordGameParams params;

  @override
  void initState() {
    super.initState();
    params = WordGameParams(
      mode: widget.mode,
      selectedValue: widget.selectedValue,
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
        ref.read(wordGameProvider(params).notifier).onShakeAnimationComplete();
      }
    });

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

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
    final params = WordGameParams(
      mode: widget.mode,
      selectedValue: widget.selectedValue,
    );
    final state = ref.watch(wordGameProvider(params));
    final notifier = ref.read(wordGameProvider(params).notifier);
    final userDataAsync = ref.watch(userDataProvider);
    final userAsync = ref.watch(firebaseUserProvider);
    final user = userAsync.value; // User? (null = not signed in)

    final sfx = ref.watch(sfxProvider);

    if (state.isShaking && !_shakeController.isAnimating) {
      _shakeController.forward(from: 0);
      if (!kIsWeb) {
        sfx.wrong();
      }
    }
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == "daily"
              ? l10n.dailyWord
              : l10n.categoryTitle(widget.selectedValue),
        ),
        actions: [
          AnimatedBuilder(
            animation: _goldAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _goldScaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color:
                            _goldColorAnimation.value ?? Colors.amber.shade800,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      if (user == null)
                        Text(
                          '0',
                          style: TextStyle(
                            color:
                                _goldColorAnimation.value ??
                                Colors.amber.shade800,
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
                                color:
                                    _goldColorAnimation.value ??
                                    Colors.amber.shade800,
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
                              color:
                                  _goldColorAnimation.value ??
                                  Colors.amber.shade800,
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
      body: state.words.when(
        data: (words) {
          if (state.currentWord == null) {
            return const Center(child: RefreshProgressIndicator());
          }

          final currentLanguage = Localizations.localeOf(context).languageCode;
          final hint = state.currentWord!.pickDisplayTerm(currentLanguage);

          // Fixed heights and paddings for the power-ups bar
          const double barHeight = 72;
          const double barVerticalPadding = 12;

          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n.yourWord}: $hint',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value *
                                sin(
                                  2 *
                                      pi *
                                      DateTime.now().millisecondsSinceEpoch /
                                      100,
                                ),
                            0,
                          ),
                          child: child,
                        ),
                        child: WordAnswerBoard(
                          text: state.currentTarget,
                          controllers: state.controllers,
                          focusNodes: state.focusNodes,
                          correct: state.correctIndices,
                          onKeyEvent: (i, e) => notifier.onKeyEvent(i, e),
                          onChanged: (i, v) =>
                              notifier.onTextChanged(context, i, v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: barVerticalPadding),
                    child: Center(
                      child: Container(
                        height: barHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: PowerUpsBar(
                          canRevealLetter:
                              state.hintIndices.length <
                              state.currentTarget.replaceAll(' ', '').length,
                          canSkip: (state.words.value?.isNotEmpty ?? false),
                          onRevealLetter: () {
                            _triggerGoldAnimation();
                            notifier.showHintLetter(context, cost: 5);
                          },
                          onSkipToNext: () async {
                            _triggerGoldAnimation();
                            await notifier.skipToNextWord(context, cost: 15);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (state.isLoading) ...[
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Colors.transparent),
                  ),
                ),
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.12),
                      child: const Center(child: CircularProgressIndicator()),
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
    );
  }
}
