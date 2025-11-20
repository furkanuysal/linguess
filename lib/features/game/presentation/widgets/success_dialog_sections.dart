import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

/// Various sections/widgets used in the SuccessDialog.

// Displays a row of information with a label and value.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ],
    );
  }
}

/// A container with a shiny/pulsing effect.
class ShinyContainer extends StatefulWidget {
  const ShinyContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.backgroundColor,
    this.borderColor,
    this.duration = const Duration(seconds: 2),
    this.shimmerWidthFactor = 0.15,
    this.shimmerOpacity = 0.7,
    this.pulseAmount = 0.02,
    this.enableShimmer = true,
    this.enablePulse = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Duration duration;
  final double shimmerWidthFactor;
  final double shimmerOpacity;
  final double pulseAmount;
  final bool enableShimmer;
  final bool enablePulse;

  @override
  State<ShinyContainer> createState() => _ShinyContainerState();
}

class _ShinyContainerState extends State<ShinyContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Accessibility/animation preferences
    final mq = MediaQuery.maybeOf(context);
    final reduceMotion =
        mq?.accessibleNavigation == true || mq?.disableAnimations == true;
    final tickerOn = TickerMode.of(context);

    if (reduceMotion ||
        !tickerOn ||
        (!widget.enablePulse && !widget.enableShimmer)) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShinyContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final mq = MediaQuery.maybeOf(context);
    final reduceMotion =
        mq?.accessibleNavigation == true || mq?.disableAnimations == true;
    final tickerOn = TickerMode.of(context);
    if (reduceMotion ||
        !tickerOn ||
        (!widget.enablePulse && !widget.enableShimmer)) {
      if (_ctrl.isAnimating) _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.backgroundColor ?? scheme.secondaryContainer;
    final br = widget.borderColor ?? scheme.secondary.withValues(alpha: 0.4);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        final pulseScale = widget.enablePulse
            ? (1.0 + widget.pulseAmount * math.sin(t * 2 * math.pi))
            : 1.0;

        // Shimmer direction: LTR → left to right, RTL → right to left
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        final dir = isRTL ? -1.0 : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: widget.borderRadius,
              border: Border.all(color: br, width: 1),
            ),
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: widget.borderRadius,
                child: widget.enableShimmer
                    ? ShaderMask(
                        shaderCallback: (rect) {
                          final w = rect.width == 0 ? 1.0 : rect.width;
                          final dx = (w * (t * 1.2 % 1.0)) * dir;
                          final width = (w * widget.shimmerWidthFactor).clamp(
                            1.0,
                            w,
                          );
                          // Start, middle, and end points aligned with direction
                          final start = ((dx / w) + (isRTL ? 1 : 0)).clamp(
                            0.0,
                            1.0,
                          );
                          final mid = (((dx + width) / w) + (isRTL ? 1 : 0))
                              .clamp(0.0, 1.0);
                          final end = (((dx + width * 2) / w) + (isRTL ? 1 : 0))
                              .clamp(0.0, 1.0);

                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(
                                alpha: widget.shimmerOpacity,
                              ),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: [start, mid, end],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.srcATop,
                        child: widget.child,
                      )
                    : widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Displays the amount of gold earned with an animation.
class GoldEarned extends StatefulWidget {
  const GoldEarned({super.key, required this.amount});
  final int amount;

  @override
  State<GoldEarned> createState() => _GoldEarnedState();
}

class _GoldEarnedState extends State<GoldEarned>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _blink;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blink = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.amount == 0) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.maybeOf(context);
    final reduceMotion =
        mq?.accessibleNavigation == true || mq?.disableAnimations == true;
    final tickerOn = TickerMode.of(context);
    if (reduceMotion || !tickerOn) {
      if (_ctrl.isAnimating) _ctrl.stop();
    } else {
      if (widget.amount == 0 && !_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GoldEarned oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amount == 0 && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
    if (widget.amount > 0 && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;

    return FadeTransition(
      opacity: Tween<double>(begin: .5, end: 1.0).animate(_blink),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on_rounded, size: 28, color: color),
          const SizedBox(width: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.amount),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Displays the amount of XP earned with an animation.
class XpEarned extends StatefulWidget {
  const XpEarned({super.key, required this.amount});
  final int amount;

  @override
  State<XpEarned> createState() => _XpEarnedState();
}

class _XpEarnedState extends State<XpEarned>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _blink;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blink = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.amount == 0) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.maybeOf(context);
    final reduceMotion =
        mq?.accessibleNavigation == true || mq?.disableAnimations == true;
    final tickerOn = TickerMode.of(context);
    if (reduceMotion || !tickerOn) {
      if (_ctrl.isAnimating) _ctrl.stop();
    } else {
      if (widget.amount == 0 && !_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant XpEarned oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amount == 0 && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
    if (widget.amount > 0 && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return FadeTransition(
      opacity: Tween<double>(begin: .5, end: 1.0).animate(_blink),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_rounded, size: 28, color: color),
          const SizedBox(width: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.amount),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => Text(
              '$value XP',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A burst of coin icons that animate outward from the center.
class CoinBurst extends StatefulWidget {
  const CoinBurst({
    super.key,
    required this.coinCount,
    this.duration = const Duration(milliseconds: 650),
    this.color, // Optional color override
  });

  final int coinCount;
  final Duration duration;
  final Color? color;

  @override
  State<CoinBurst> createState() => _CoinBurstState();
}

class _CoinBurstState extends State<CoinBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _particles = _spawnParticles(widget.coinCount);
  }

  // Reduce motion / TickerMode control
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mq = MediaQuery.maybeOf(context);
    final reduceMotion =
        mq?.accessibleNavigation == true || mq?.disableAnimations == true;
    final tickerOn = TickerMode.of(context);
    if (reduceMotion || !tickerOn) {
      if (_ctrl.isAnimating) _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.forward(from: _ctrl.value == 1.0 ? 0.0 : _ctrl.value);
    }
  }

  // Restart animation if coinCount/duration is updated
  @override
  void didUpdateWidget(covariant CoinBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coinCount != widget.coinCount ||
        oldWidget.duration != widget.duration) {
      _particles = _spawnParticles(widget.coinCount);
      _ctrl.duration = widget.duration;
      _ctrl
        ..reset()
        ..forward();
    }
  }

  List<_Particle> _spawnParticles(int n) {
    final rnd = math.Random();
    final count = n.clamp(0, 64); // ceiling safety
    return List.generate(count, (i) {
      final angle =
          (i / (count == 0 ? 1 : count)) * 2 * math.pi +
          rnd.nextDouble() * 0.5; // slight randomness
      final distance = 48 + rnd.nextDouble() * 28;
      final size = 16.0 + rnd.nextDouble() * 8.0;
      final delay = rnd.nextDouble() * .1; // 0..0.1
      return _Particle(
        angle: angle,
        distance: distance,
        size: size,
        delay: delay,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Guard: if no coins or particles, return empty
    if (widget.coinCount <= 0 || _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = widget.color ?? Theme.of(context).colorScheme.tertiary;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return IgnorePointer(
          ignoring: true,
          child: RepaintBoundary(
            // isolation
            child: Stack(
              clipBehavior: Clip.none,
              children: _particles.map((p) {
                final t = ((_ctrl.value - p.delay) / (1 - p.delay)).clamp(
                  0.0,
                  1.0,
                );
                // A bit more “smooth” easing
                final eased = Curves.easeOutCubic.transform(t);
                final dx = math.cos(p.angle) * p.distance * eased;
                final dy = math.sin(p.angle) * p.distance * eased;
                final scale = (1.0 - .6 * eased);
                // Fade out opacity with a slight ease instead of linear
                final fade = Curves.easeOut.transform(1 - t);

                return Opacity(
                  opacity: fade,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: Transform.scale(
                      scale: scale,
                      child: Icon(
                        Icons.monetization_on_rounded,
                        size: p.size,
                        color: color,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
  final double angle;
  final double distance;
  final double size;
  final double delay;
}

// Displays the user's progress towards learning a word.
class WordProgressSection extends StatelessWidget {
  const WordProgressSection({
    super.key,
    required this.count,
    required this.requiredTimes,
  });
  final int count;
  final int requiredTimes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // If exceeded required times, show a badge instead of progress bar
    if (count > requiredTimes) {
      return Center(child: ShinyBadge(text: l10n.learnedWordText));
    }

    final capped = count.clamp(0, requiredTimes);
    final prevFrac = ((count - 1).clamp(0, requiredTimes)) / requiredTimes;
    final targetFrac = capped / requiredTimes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: prevFrac, end: targetFrac),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, frac, _) {
                  return _ProgressWithBubble(
                    fraction: frac,
                    label: '$capped/$requiredTimes',
                    trackHeight: 8,
                    bubbleOffset: 8,
                    horizontalPadding: 6,
                    trackBg: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.6,
                    ),
                    trackFg: (capped >= requiredTimes)
                        ? Colors.green
                        : scheme.primary,
                    bubbleColor: scheme.secondaryContainer,
                    bubbleTextStyle: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // If just reached the required times, show a "just learned" chip
        if (count == requiredTimes)
          Align(
            alignment: Alignment.center,
            child: ShinyChip(text: l10n.theWordIsLearnedText),
          ),
      ],
    );
  }
}

// A small chip with an icon and text that has a shiny effect.
class ShinyChip extends StatelessWidget {
  const ShinyChip({
    super.key,
    required this.text,
    this.icon = Icons.school_rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  final String text;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ShinyContainer(
      padding: padding,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      shimmerWidthFactor: 0.12, // Chip is narrower; reduced shimmer width
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// A badge with an icon and text that has a shiny effect.
class ShinyBadge extends StatelessWidget {
  const ShinyBadge({
    super.key,
    required this.text,
    this.icon = Icons.verified_rounded,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShinyContainer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ProgressWithBubble extends StatelessWidget {
  const _ProgressWithBubble({
    required this.fraction,
    required this.label,
    required this.trackHeight,
    required this.trackBg,
    required this.trackFg,
    required this.bubbleColor,
    this.bubbleTextStyle,
    this.horizontalPadding = 6, // left/right padding
    this.bubbleOffset = 8, // bubble height offset
  });

  final double fraction; // 0..1
  final String label; // like "3/5"
  final double trackHeight;
  final Color trackBg;
  final Color trackFg;
  final Color bubbleColor;
  final TextStyle? bubbleTextStyle;
  final double horizontalPadding;
  final double bubbleOffset;

  @override
  Widget build(BuildContext context) {
    // RTL support: reverse bubble position
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final f = fraction.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bubbleWidth = _estimateBubbleWidth(label, bubbleTextStyle);
        // Prevent overflow to the left/right
        final minX = horizontalPadding + bubbleWidth / 2;
        final maxX = w - horizontalPadding - bubbleWidth / 2;
        final x = (isRTL ? (1 - f) : f) * w;
        final clampedX = x.clamp(minX, maxX);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: trackHeight + bubbleOffset,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: trackBg),
                    FractionallySizedBox(
                      widthFactor: f,
                      alignment: Alignment.centerLeft,
                      child: Container(color: trackFg),
                    ),
                  ],
                ),
              ),
            ),
            // Speech bubble
            Positioned(
              left: clampedX - bubbleWidth / 2,
              top: trackHeight + bubbleOffset,
              child: _SpeechBubble(
                text: label,
                color: bubbleColor,
                textStyle: bubbleTextStyle,
                isAbove: false,
              ),
            ),
          ],
        );
      },
    );
  }

  double _estimateBubbleWidth(String text, TextStyle? style) {
    final base = (text.length * 7.0) + 16.0; // text + inner padding estimate
    final min = 36.0, max = 120.0;
    return base.clamp(min, max);
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.color,
    this.textStyle,
    this.isAbove = true, // default: above
  });

  final String text;
  final Color color;
  final TextStyle? textStyle;
  final bool isAbove;

  @override
  Widget build(BuildContext context) {
    final ts = textStyle ?? Theme.of(context).textTheme.labelSmall;
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Text(text, style: ts),
    );

    final arrow = CustomPaint(
      size: const Size(10, 6),
      painter: _TrianglePainter(color, isAbove: isAbove),
    );

    return isAbove
        ? Column(
            children: [
              bubble,
              Transform.translate(offset: const Offset(0, -1), child: arrow),
            ],
          )
        : Column(
            children: [
              Transform.translate(offset: const Offset(0, 1), child: arrow),
              bubble,
            ],
          );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color, {this.isAbove = true});
  final Color color;
  final bool isAbove;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (isAbove) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0)
        ..close();
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isAbove != isAbove;
}
