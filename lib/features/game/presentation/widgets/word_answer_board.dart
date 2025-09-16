import 'dart:math' as math;
import 'package:flutter/material.dart';

typedef OnKeyEvt = bool Function(int logicalIndex, KeyEvent event);
typedef OnChanged = void Function(int logicalIndex, String value);

class WordAnswerBoard extends StatelessWidget {
  const WordAnswerBoard({
    super.key,
    required this.text,
    required this.controllers,
    required this.focusNodes,
    required this.correct,
    required this.onKeyEvent,
    required this.onChanged,
    this.horizontalPadding = 32.0,
    this.letterGap = 8.0,
    this.wordGapFactor = 1.00,
    this.minBoxWidth = 20.0,
    this.maxBoxWidth = 40.0,
    this.lineGap = 12.0,
  });

  final String text;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<bool> correct;
  final OnKeyEvt onKeyEvent;
  final OnChanged onChanged;

  // layout
  final double horizontalPadding;
  final double letterGap;
  final double wordGapFactor;
  final double minBoxWidth;
  final double maxBoxWidth;
  final double lineGap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = screenWidth - horizontalPadding * 2;

    // split into words (normalize)
    final parts = text.trim().split(RegExp(r'\s+'));

    // box width if lineWords fit in a single line
    double computeWFit(List<String> lineWords) {
      int totalLetters = 0;
      int intraGapsCount = 0;
      for (final w in lineWords) {
        final L = w.runes.length; // unicode safe
        if (L <= 0) continue;
        totalLetters += L;
        intraGapsCount += (L - 1);
      }
      if (totalLetters == 0) return maxBoxWidth;
      final intraGaps = intraGapsCount * letterGap;
      final denom =
          totalLetters +
          (lineWords.length > 1 ? (lineWords.length - 1) * wordGapFactor : 0.0);
      return (maxContentWidth - intraGaps) / denom;
    }

    // Greedy line filling
    final List<List<String>> lines = [];
    List<String> current = [];
    for (final w in parts) {
      if (w.isEmpty) continue;
      final tentative = [...current, w];
      final wFit = computeWFit(tentative);

      if (tentative.length == 1) {
        current = tentative; // single word line
      } else {
        if (wFit >= minBoxWidth) {
          current = tentative;
        } else {
          if (current.isNotEmpty) lines.add(current);
          current = [w];
        }
      }
    }
    if (current.isNotEmpty) lines.add(current);

    // controller/focus indices (excluding spaces)
    int runningLogical = -1;
    final totalBoxes = controllers.length;

    Widget buildLetterBoxAt(int li, double width) {
      if (li < 0 || li >= totalBoxes) return const SizedBox.shrink(); // guard
      final w = width.clamp(10.0, maxBoxWidth);
      return SizedBox(
        width: w,
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) => onKeyEvent(li, event),
          child: TextField(
            controller: controllers[li],
            focusNode: focusNodes[li],
            enabled: !correct[li],
            textAlign: TextAlign.center,
            maxLength: 1,
            onChanged: (val) => onChanged(li, val),
            decoration: const InputDecoration(counterText: ''),
            style: TextStyle(
              fontSize: 22,
              color: correct[li] ? Colors.green : scheme.onSurface,
            ),
          ),
        ),
      );
    }

    Widget buildLine(List<String> wordsInLine) {
      final wFit = computeWFit(wordsInLine);
      final boxW = math.max(wFit, minBoxWidth);
      final gapBetweenWords = boxW * wordGapFactor;
      final needsScroll = (wordsInLine.length == 1 && wFit < minBoxWidth);

      int remaining = math.max(0, totalBoxes - (runningLogical + 1));

      Widget row = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int wi = 0; wi < wordsInLine.length && remaining > 0; wi++) ...[
            if (wi > 0) SizedBox(width: gapBetweenWords),
            Builder(
              builder: (context) {
                final runes = wordsInLine[wi].runes.toList();
                final take = math.min(remaining, runes.length);
                remaining -= take;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < take; i++) ...[
                      if (i > 0) SizedBox(width: letterGap),
                      buildLetterBoxAt(++runningLogical, boxW),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      );

      if (needsScroll) {
        row = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: row,
        );
      }
      return row;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int li = 0; li < lines.length; li++) ...[
              buildLine(lines[li]),
              if (li < lines.length - 1) SizedBox(height: lineGap),
            ],
          ],
        ),
      ),
    );
  }
}
