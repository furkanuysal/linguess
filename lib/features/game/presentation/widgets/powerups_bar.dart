import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class PowerUpsBar extends StatelessWidget {
  const PowerUpsBar({
    super.key,
    required this.canRevealLetter,
    required this.canSkip,
    required this.onRevealLetter,
    required this.onSkipToNext,
  });

  final bool canRevealLetter;
  final bool canSkip;
  final VoidCallback onRevealLetter;
  final VoidCallback onSkipToNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: 1.5,
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _PowerUpChip(
                icon: Icons.lightbulb_outline,
                cost: 5,
                enabled: canRevealLetter,
                onTap: onRevealLetter,
                tooltip: canRevealLetter
                    ? l10n.letterHint
                    : l10n.allLettersRevealed,
              ),
              const SizedBox(width: 8),
              _PowerUpChip(
                icon: Icons.skip_next_outlined,
                cost: 15,
                enabled: canSkip,
                onTap: onSkipToNext,
                tooltip: canSkip ? l10n.skipToNext : l10n.nothingToSkip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PowerUpChip extends StatelessWidget {
  const _PowerUpChip({
    required this.icon,
    required this.cost,
    required this.enabled,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final int cost;
  final bool enabled;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final chipCore = Semantics(
      label: 'Power-up — $cost gold',
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.5,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.shade400,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(icon, size: 24, color: Colors.brown.shade800),
                ),
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cost.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return tooltip == null
        ? chipCore
        : Tooltip(message: tooltip!, child: chipCore);
  }
}
