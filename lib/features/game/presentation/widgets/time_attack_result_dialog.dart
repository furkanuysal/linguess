import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class TimeAttackResultDialog {
  static Future<void> show(
    BuildContext context, {
    required int correctCount,
    required int totalGoldEarned,
    required VoidCallback onRestart,
    int earlyCompletionBonus = 0,
    int consolationReward = 0,
    bool noWordSolved = false,
  }) async {
    final scheme = Theme.of(context).colorScheme;

    final effectiveTotal =
        totalGoldEarned + earlyCompletionBonus + consolationReward;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: scheme.surface.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _AnimatedResultContent(
              totalGold: totalGoldEarned,
              earlyBonus: earlyCompletionBonus,
              consolation: consolationReward,
              effectiveTotal: effectiveTotal,
              onRestart: onRestart,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedResultContent extends StatefulWidget {
  final int totalGold;
  final int earlyBonus;
  final int consolation;
  final int effectiveTotal;
  final VoidCallback onRestart;

  const _AnimatedResultContent({
    required this.totalGold,
    required this.earlyBonus,
    required this.consolation,
    required this.effectiveTotal,
    required this.onRestart,
  });

  @override
  State<_AnimatedResultContent> createState() => _AnimatedResultContentState();
}

class _AnimatedResultContentState extends State<_AnimatedResultContent>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  int _goldShown = 0;
  int _bonusShown = 0;
  int _consolationShown = 0;
  int _totalShown = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _animateCount(
      target: widget.totalGold,
      onUpdate: (v) => setState(() => _goldShown = v),
    );
    if (widget.earlyBonus > 0) {
      await Future.delayed(const Duration(milliseconds: 400));
      await _animateCount(
        target: widget.earlyBonus,
        onUpdate: (v) => setState(() => _bonusShown = v),
      );
    }
    if (widget.consolation > 0) {
      await Future.delayed(const Duration(milliseconds: 400));
      await _animateCount(
        target: widget.consolation,
        onUpdate: (v) => setState(() => _consolationShown = v),
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));
    await _animateCount(
      target: widget.effectiveTotal,
      onUpdate: (v) => setState(() => _totalShown = v),
      stepDuration: 20,
    );
  }

  Future<void> _animateCount({
    required int target,
    required Function(int) onUpdate,
    int stepDuration = 15,
  }) async {
    int current = 0;
    final int increment = (target / 25).ceil().clamp(1, target);
    while (current < target) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      current = (current + increment).clamp(0, target);
      onUpdate(current);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final bool hasBonuses = widget.earlyBonus > 0 || widget.consolation > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_circle_rounded, color: scheme.primary, size: 38),
            const SizedBox(width: 8),
            Text(
              l10n.timeAttackEndedTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 20),

        // Gold Breakdown
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AnimatedLine(
                visible: _goldShown > 0 || widget.totalGold == 0,
                text: l10n.goldEarnedFromSolvedWords(_goldShown),
                color: scheme.onSurface,
              ),
              if (widget.earlyBonus > 0)
                _AnimatedLine(
                  visible: _bonusShown > 0,
                  text: l10n.earlyCompletionBonusGold(_bonusShown),
                  color: scheme.onSurface,
                ),
              if (widget.consolation > 0)
                _AnimatedLine(
                  visible: _consolationShown > 0,
                  text: l10n.consolationRewardGold(_consolationShown),
                  color: scheme.onSurface,
                ),

              if (hasBonuses) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: Divider(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                    thickness: 1,
                  ),
                ),
              ],

              const SizedBox(height: 6),

              _AnimatedLine(
                visible: _totalShown > 0,
                text: l10n.totalGoldEarned(_totalShown),
                color: scheme.primary,
                isBold: true,
                fontSize: 18,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  context.pop();
                  widget.onRestart();
                },
                icon: const Icon(Icons.replay_rounded),
                label: Text(
                  l10n.tryAgainText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: scheme.primary.withValues(alpha: 0.6),
                    width: 1.3,
                  ),
                ),
                onPressed: () {
                  context.pop();
                  context.go('/');
                },
                icon: Icon(Icons.home_rounded, color: scheme.primary),
                label: Text(
                  l10n.returnToMainMenu,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedLine extends StatelessWidget {
  final bool visible;
  final String text;
  final Color color;
  final bool isBold;
  final double fontSize;

  const _AnimatedLine({
    required this.visible,
    required this.text,
    required this.color,
    this.isBold = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
