import 'package:flutter/material.dart';
import 'package:linguess/core/effects/confetti_particle.dart';
import 'package:linguess/features/game/presentation/widgets/success_dialog_sections.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class SuccessDialog extends StatefulWidget {
  const SuccessDialog({
    super.key,
    required this.goldEarned, // Gold earned in this round (can be 0 if too many hints used)
    required this.askedWordInAppLang, // The word solved by the player (in user language)
    required this.correctAnswer, // The correct English answer
    required this.correctTimes, // How many times this word was answered correctly (0..requiredTimes)
    this.requiredTimes =
        5, // Number of repetitions required to be considered learned
    required this.isDaily, // Is it in daily mode?
    this.onPrimaryPressed, // Callback to run when CTA is pressed (e.g. load new word / close)
  });

  final int goldEarned;
  final String askedWordInAppLang;
  final String correctAnswer;
  final int correctTimes;
  final int requiredTimes;
  final bool isDaily;
  final VoidCallback? onPrimaryPressed;

  static Future<void> show(
    BuildContext context, {
    required int goldEarned,
    required String askedWordInAppLang,
    required String correctAnswer,
    required int correctTimes,
    int requiredTimes = 5,
    required bool isDaily,
    VoidCallback? onPrimaryPressed,
    bool showConfetti = true,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          if (showConfetti)
            const Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(child: SizedBox.expand()),
              ),
            ),
          Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SuccessDialog(
              goldEarned: goldEarned,
              askedWordInAppLang: askedWordInAppLang,
              correctAnswer: correctAnswer,
              correctTimes: correctTimes,
              requiredTimes: requiredTimes,
              isDaily: isDaily,
              onPrimaryPressed: onPrimaryPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Scale in with a bit of overshoot
    _scaleIn = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    // Start the animation
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = widget.correctTimes;
    final req = widget.requiredTimes;

    final primaryLabel = widget.isDaily ? l10n.close : l10n.nextWord;

    return ScaleTransition(
      scale: _scaleIn,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Correct Text
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.correctText}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gold Earned + Coin Burst
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.goldEarned > 0)
                    CoinBurst(
                      key: ValueKey('coin-burst-${widget.goldEarned}'),
                      coinCount: (8 + (widget.goldEarned / 10).clamp(0, 10))
                          .toInt(),
                      duration: const Duration(milliseconds: 1500),
                    ),
                  // Gold Earned
                  GoldEarned(amount: widget.goldEarned),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1),
              const SizedBox(height: 12),

              // Asked Word (in app language)
              InfoRow(label: l10n.yourWord, value: widget.askedWordInAppLang),
              const SizedBox(height: 6),
              // Correct Answer
              InfoRow(label: l10n.correctAnswer, value: widget.correctAnswer),

              const SizedBox(height: 14),

              WordProgressSection(count: count, requiredTimes: req),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onPrimaryPressed?.call();
                  },
                  child: Text(primaryLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
