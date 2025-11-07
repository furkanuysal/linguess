import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopHeader extends ConsumerStatefulWidget {
  final int gold;
  final int level;

  const ShopHeader({super.key, required this.gold, required this.level});

  @override
  ConsumerState<ShopHeader> createState() => _ShopHeaderState();
}

class _ShopHeaderState extends ConsumerState<ShopHeader>
    with TickerProviderStateMixin {
  late AnimationController _goldAnimationController;
  late Animation<double> _goldScaleAnimation;
  late Animation<Color?> _goldColorAnimation;

  int _lastGold = 0;

  @override
  void initState() {
    super.initState();

    _goldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
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

    _lastGold = widget.gold;
  }

  @override
  void didUpdateWidget(covariant ShopHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.gold < _lastGold) {
      _goldAnimationController.forward(from: 0).then((_) {
        _goldAnimationController.reverse();
      });
    }

    _lastGold = widget.gold;
  }

  @override
  void dispose() {
    _goldAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Material(
        elevation: 1.5,
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gold (Animated)
              AnimatedBuilder(
                animation: _goldAnimationController,
                builder: (context, child) {
                  final chipColor =
                      _goldColorAnimation.value ?? Colors.amber.shade800;
                  return Transform.scale(
                    scale: _goldScaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          if (_goldAnimationController.isAnimating)
                            BoxShadow(
                              color: chipColor.withValues(alpha: 0.35),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            color: chipColor,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.gold}',
                            style: TextStyle(
                              color: chipColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Level (Static)
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.orangeAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.level}: ${widget.level}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
