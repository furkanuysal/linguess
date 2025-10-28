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
    bool isSignedIn = true,
    VoidCallback? onSignInPressed,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final effectiveTotal =
        totalGoldEarned + earlyCompletionBonus + consolationReward;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: scheme.surface.withValues(alpha: 0.96),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _AnimatedResultContent(
                  totalGold: totalGoldEarned,
                  earlyBonus: earlyCompletionBonus,
                  consolation: consolationReward,
                  effectiveTotal: effectiveTotal,
                  onRestart: onRestart,
                  correctCount: correctCount,
                  isSignedIn: isSignedIn,
                  onSignInPressed: onSignInPressed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedResultContent extends StatefulWidget {
  final int totalGold;
  final int earlyBonus;
  final int consolation;
  final int effectiveTotal;
  final int correctCount;
  final VoidCallback onRestart;
  final bool isSignedIn;
  final VoidCallback? onSignInPressed;

  const _AnimatedResultContent({
    required this.totalGold,
    required this.earlyBonus,
    required this.consolation,
    required this.effectiveTotal,
    required this.onRestart,
    required this.correctCount,
    required this.isSignedIn,
    this.onSignInPressed,
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

    if (widget.isSignedIn) _startSequence();
  }

  Future<void> _startSequence() async {
    await _animateCount(widget.totalGold, (v) => _goldShown = v);
    if (widget.earlyBonus > 0) {
      await Future.delayed(const Duration(milliseconds: 400));
      await _animateCount(widget.earlyBonus, (v) => _bonusShown = v);
    }
    if (widget.consolation > 0) {
      await Future.delayed(const Duration(milliseconds: 400));
      await _animateCount(widget.consolation, (v) => _consolationShown = v);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    await _animateCount(
      widget.effectiveTotal,
      (v) => _totalShown = v,
      stepDuration: 20,
    );
  }

  Future<void> _animateCount(
    int target,
    void Function(int) setVal, {
    int stepDuration = 15,
  }) async {
    int current = 0;
    final increment = (target / 25).ceil().clamp(1, target);
    while (current < target) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      setState(() {
        current = (current + increment).clamp(0, target);
        setVal(current);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final hasBonuses = widget.earlyBonus > 0 || widget.consolation > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Row(
          children: [
            Icon(Icons.flag_circle_rounded, color: scheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              l10n.timeAttackEndedTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Correct count
        Text(
          l10n.correctCountText(widget.correctCount),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Divider(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 8),

        // Gold information (only if signed in)
        if (widget.isSignedIn)
          Column(
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
                Divider(color: scheme.outlineVariant.withValues(alpha: 0.4)),
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
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              l10n.progressNotSaved,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 16),

        // CTA Field
        if (widget.isSignedIn)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.pop();
                    widget.onRestart();
                  },
                  child: Text(l10n.tryAgainText),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop();
                    context.go('/');
                  },
                  child: Text(l10n.returnToMainMenu),
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upsell kartı
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.signInUpsellText,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onSignInPressed,
                icon: const Icon(Icons.login),
                label: Text(l10n.signIn),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  context.pop();
                  widget.onRestart();
                },
                child: Text(l10n.continueToPlayAsGuest),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  context.pop();
                  context.go('/');
                },
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.returnToMainMenu),
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
