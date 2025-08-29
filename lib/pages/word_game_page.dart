import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/word_game_state.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import 'package:linguess/providers/user_data_provider.dart';
import 'package:linguess/providers/word_game_provider.dart';

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
  final GlobalKey _wrapKey = GlobalKey();
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

    if (state.isShaking && !_shakeController.isAnimating) {
      _shakeController.forward(from: 0);
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
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed:
                state.hintIndices.length >=
                    state.currentTarget.replaceAll(' ', '').length
                ? null
                : () {
                    _triggerGoldAnimation();
                    notifier.showHintLetter(context);
                  },
            tooltip: l10n.letterHint,
          ),
        ],
      ),
      body: state.words.when(
        data: (words) {
          if (state.currentWord == null) {
            return Center(child: Text(l10n.comingSoon));
          }
          final String currentLanguage = Localizations.localeOf(
            context,
          ).languageCode;
          final String hint =
              state.currentWord!.translations[currentLanguage] ?? '???';

          final screenWidth = MediaQuery.of(context).size.width;
          const boxSpacing = 8.0;
          const horizontalPadding = 32.0;
          const maxBoxWidth = 40.0;

          final letterCount = state.currentTarget.replaceAll(' ', '').length;
          final spaceCount = ' '.allMatches(state.currentTarget).length;

          final totalElementCount = state.currentTarget.length;
          final totalSpacing = (totalElementCount - 1) * boxSpacing;
          final totalSpaceWidth = spaceCount * (maxBoxWidth / 2);
          final availableWidth =
              screenWidth - horizontalPadding - totalSpacing - totalSpaceWidth;

          double boxWidth = availableWidth / letterCount;
          if (boxWidth > maxBoxWidth) {
            boxWidth = maxBoxWidth;
          }

          final scheme = Theme.of(context).colorScheme;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.yourWord}: $hint',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        return Transform.translate(
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
                          child: Wrap(
                            key: _wrapKey,
                            spacing: boxSpacing,
                            children: List.generate(
                              state.currentTarget.length,
                              (index) {
                                if (state.currentTarget[index] == ' ') {
                                  return SizedBox(width: boxWidth / 2);
                                } else {
                                  final logicalIndex = notifier
                                      .logicalIndexFromVisual(index);
                                  return SizedBox(
                                    width: boxWidth,
                                    child: KeyboardListener(
                                      focusNode: FocusNode(),
                                      onKeyEvent: (event) {
                                        notifier.onKeyEvent(
                                          logicalIndex,
                                          event,
                                        );
                                      },
                                      child: TextField(
                                        controller:
                                            state.controllers[logicalIndex],
                                        focusNode:
                                            state.focusNodes[logicalIndex],
                                        enabled:
                                            !state.correctIndices[logicalIndex],
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        onChanged: (val) =>
                                            notifier.onTextChanged(
                                              context,
                                              logicalIndex,
                                              val,
                                            ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                        ),
                                        style: TextStyle(
                                          fontSize: 22,
                                          color:
                                              state.correctIndices[logicalIndex]
                                              ? Colors.green
                                              : scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('${l10n.errorOccurred}: $error')),
      ),
    );
  }
}
