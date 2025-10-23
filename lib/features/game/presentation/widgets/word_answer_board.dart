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
    this.wordGap = 24.0,
    this.boxWidth = 36.0,
    this.boxHeight = 36.0,
    this.lineGap = 12.0,
    this.maxContentWidth = 600.0,
  });

  final String text;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final List<bool> correct;
  final OnKeyEvt onKeyEvent;
  final OnChanged onChanged;

  final double horizontalPadding;
  final double letterGap;
  final double wordGap;
  final double boxWidth;
  final double boxHeight;
  final double lineGap;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = math.min(
      screenWidth - horizontalPadding * 2,
      maxContentWidth,
    );

    // Group words into lines that fit within effectiveWidth
    final parts = text.trim().split(RegExp(r'\s+'));
    final List<List<String>> lines = [];
    List<String> current = [];
    double currentLineWidth = 0.0;

    for (final w in parts) {
      final wordWidth = (w.length * boxWidth) + ((w.length - 1) * letterGap);
      final extraGap = current.isEmpty ? 0 : wordGap;

      // If the line is full, move to the next line
      if (currentLineWidth + wordWidth + extraGap > effectiveWidth &&
          current.isNotEmpty) {
        lines.add(current);
        current = [w];
        currentLineWidth = wordWidth;
      } else {
        current.add(w);
        currentLineWidth += wordWidth + extraGap;
      }
    }
    if (current.isNotEmpty) lines.add(current);

    int runningLogical = -1;
    final totalBoxes = controllers.length;

    Widget buildLetterBoxAt(int li) {
      if (li < 0 || li >= totalBoxes) return const SizedBox.shrink();
      return SizedBox(
        width: boxWidth,
        height: boxHeight,
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
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              counterText: '',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: scheme.surfaceContainerHighest,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: scheme.surfaceContainerHigh,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            style: TextStyle(
              fontSize: 22,
              color: correct[li] ? Colors.green : scheme.onSurface,
            ),
          ),
        ),
      );
    }

    // Build each line of words
    Widget buildLine(List<String> wordsInLine) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int wi = 0; wi < wordsInLine.length; wi++) ...[
            if (wi > 0) SizedBox(width: wordGap),
            Builder(
              builder: (context) {
                final word = wordsInLine[wi];
                final wordWidth =
                    (word.length * boxWidth) + ((word.length - 1) * letterGap);
                final isLong = wordWidth > effectiveWidth;
                final viewportWidth = isLong ? effectiveWidth : wordWidth;

                final wordRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < word.runes.length; i++) ...[
                      if (i > 0) SizedBox(width: letterGap),
                      buildLetterBoxAt(++runningLogical),
                    ],
                  ],
                );

                return SizedBox(
                  width: viewportWidth,
                  height: boxHeight,
                  child: isLong
                      ? _EdgeFadedHScroll(
                          key: ValueKey("$text-$wi"),
                          boxHeight: boxHeight - 1.75,
                          fadeWidth: 28,
                          child: wordRow,
                        )
                      : Align(alignment: Alignment.center, child: wordRow),
                );
              },
            ),
          ],
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

class _EdgeFadedHScroll extends StatefulWidget {
  const _EdgeFadedHScroll({
    super.key,
    required this.child,
    required this.boxHeight,
    this.fadeWidth = 32,
  });

  final Widget child;
  final double boxHeight;
  final double fadeWidth;

  @override
  State<_EdgeFadedHScroll> createState() => _EdgeFadedHScrollState();
}

class _EdgeFadedHScrollState extends State<_EdgeFadedHScroll> {
  late final ScrollController _ctrl;
  bool _showLeft = false;
  bool _showRight = false;
  bool _needsScroll = false;

  void _updateFades() {
    if (!_ctrl.hasClients) return;
    final p = _ctrl.position;
    final atStart = p.pixels <= p.minScrollExtent + 0.5;
    final atEnd = p.pixels >= p.maxScrollExtent - 0.5;

    final left = !atStart;
    final right = !atEnd;

    if (left != _showLeft || right != _showRight) {
      setState(() {
        _showLeft = left;
        _showRight = right;
      });
    }
  }

  void _checkIfScrollable() {
    if (!_ctrl.hasClients) return;
    final scrollable = _ctrl.position.maxScrollExtent > 0;
    if (scrollable != _needsScroll) {
      setState(() => _needsScroll = scrollable);
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    _ctrl.addListener(_updateFades);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _updateFades();
      _checkIfScrollable();

      // Small delay to allow initial rendering
      await Future.delayed(const Duration(milliseconds: 250));

      if (!mounted) return;
      if (_needsScroll) {
        final maxScroll = _ctrl.position.maxScrollExtent;

        // Animate to the end
        await _ctrl.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );

        // Small pause
        await Future.delayed(const Duration(milliseconds: 50));

        // Animate back to start
        if (mounted) {
          await _ctrl.animateTo(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutQuart,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_updateFades);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fadeColor = scheme.surfaceContainerHighest.withValues(alpha: 0.4);
    final fadeStartColor = scheme.surfaceContainerHigh.withValues(alpha: 0.4);

    return SizedBox(
      height: widget.boxHeight,
      child: Stack(
        children: [
          ClipRect(
            child: SingleChildScrollView(
              controller: _ctrl,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Align(
                alignment: _needsScroll
                    ? Alignment.centerLeft
                    : Alignment.center,
                child: widget.child,
              ),
            ),
          ),

          if (_showLeft)
            Align(
              alignment: Alignment.centerLeft,
              child: IgnorePointer(
                child: Container(
                  width: widget.fadeWidth,
                  height: widget.boxHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [fadeColor, fadeStartColor],
                    ),
                  ),
                ),
              ),
            ),

          if (_showRight)
            Align(
              alignment: Alignment.centerRight,
              child: IgnorePointer(
                child: Container(
                  width: widget.fadeWidth,
                  height: widget.boxHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [fadeStartColor, fadeColor],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
