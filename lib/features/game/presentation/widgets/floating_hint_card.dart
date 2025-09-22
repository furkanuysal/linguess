import 'package:flutter/material.dart';

class FloatingHintCard extends StatefulWidget {
  final String title;
  final String content;
  final VoidCallback onClose;
  final Duration autoCloseDuration;

  const FloatingHintCard({
    super.key,
    required this.title,
    required this.content,
    required this.onClose,
    this.autoCloseDuration = const Duration(seconds: 8),
  });

  @override
  State<FloatingHintCard> createState() => _FloatingHintCardState();
}

class _FloatingHintCardState extends State<FloatingHintCard>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progress;

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slide;

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    // 8 sec linear progress
    _progressCtrl = AnimationController(
      vsync: this,
      duration: widget.autoCloseDuration,
    )..forward();
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.linear);

    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animateOut(); // close by sliding up when time is up
      }
    });

    // entry/exit slide animation
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.18), // start slightly above
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    // opening animation
    _slideCtrl.forward();
  }

  Future<void> _animateOut() async {
    if (_isClosing) return;
    _isClosing = true;
    // first, play the slide-up animation
    _progressCtrl.stop();
    try {
      await _slideCtrl.reverse();
    } finally {
      widget.onClose(); // remove the overlay outside
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SlideTransition(
            position: _slide,
            child: Dismissible(
              key: const ValueKey('floating-hint-card'),
              direction: DismissDirection.down,
              onDismissed: (_) => _animateOut(),
              confirmDismiss: (_) async {
                await _animateOut();
                return false;
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // progress bar (inside the card)
                    SizedBox(
                      height: 4,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedBuilder(
                            animation: _progress,
                            builder: (context, _) {
                              final remaining = 1.0 - _progress.value;
                              final w = constraints.maxWidth * remaining;
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFFFD54F),
                                        Color(0xFFFF7043),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _animateOut,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.content, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
