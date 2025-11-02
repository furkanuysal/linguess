import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/leveling/presentation/controllers/levelup_toast_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class LevelUpToastWidget extends ConsumerStatefulWidget {
  const LevelUpToastWidget({super.key});

  @override
  ConsumerState<LevelUpToastWidget> createState() => _LevelUpToastWidgetState();
}

class _LevelUpToastWidgetState extends ConsumerState<LevelUpToastWidget>
    with TickerProviderStateMixin {
  late final AnimationController _barCtrl;
  late final Animation<double> _barAnim;
  late final AnimationController _shimmerCtrl;

  String? _lastEventId;
  bool _showNewLevel = false;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutCubic);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _barCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showNewLevel = true);
        _shimmerCtrl.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(levelUpToastProvider);
    if (event == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    if (_lastEventId != event.id) {
      _lastEventId = event.id;
      _showNewLevel = false;
      _barCtrl.forward(from: 0);
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and level display
              Row(
                children: [
                  Text(
                    l10n.levelUpTitle,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    l10n.level,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (context, child) {
                      final shimmerValue = _shimmerCtrl.value;
                      final shimmerColor = Color.lerp(
                        const Color(0xFFFFF8E1),
                        const Color(0xFFFFF59D),
                        (0.5 - (shimmerValue - 0.5).abs()) * 2,
                      );
                      return Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              shimmerColor ?? const Color(0xFFFFECB3),
                              const Color(0xFFFFD54F),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, anim) {
                            final slide =
                                Tween<Offset>(
                                  begin: const Offset(0, 0.6),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                            return ClipRect(
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            '${_showNewLevel ? event.to : event.from}',
                            key: ValueKey(_showNewLevel),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Gradient progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _barAnim,
                  builder: (_, _) => ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [
                        Color(0xFFFFF59D),
                        Color(0xFFFFD54F),
                        Color(0xFFFFB300),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(rect),
                    blendMode: BlendMode.srcIn,
                    child: LinearProgressIndicator(
                      value: _barAnim.value,
                      minHeight: 6,
                      color: Colors.white,
                      backgroundColor: Colors.white30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
