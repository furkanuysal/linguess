import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
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
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = WordGameParams(
      mode: widget.mode,
      selectedValue: widget.selectedValue,
    );
    final state = ref.watch(wordGameProvider(params));
    final notifier = ref.read(wordGameProvider(params).notifier);

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
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed:
                state.hintIndices.length >=
                    state.currentTarget.replaceAll(' ', '').length
                ? null
                : () => notifier.showHintLetter(context),
            tooltip: l10n.letterHint,
          ),
        ],
      ),
      body: state.words.when(
        data: (words) {
          if (state.currentWord == null) {
            return const Center(child: CircularProgressIndicator());
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
                                    child: TextField(
                                      controller:
                                          state.controllers[logicalIndex],
                                      focusNode: state.focusNodes[logicalIndex],
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
