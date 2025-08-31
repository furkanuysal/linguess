import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/sfx/sfx_service.dart';

class ConfettiGame extends FlameGame {
  ConfettiGame({this.onBurstSound});

  final VoidCallback? onBurstSound;
  int burstPhase = 0; // 0: first burst, 1: second burst, 2: finished
  bool isWaitingForSecondBurst = false;
  double waitTimer = 0;
  static const double waitDuration = 1.5; // wait for 1.5 seconds

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // First burst
    _createBurst();
    onBurstSound?.call();
    burstPhase = 1;
    isWaitingForSecondBurst = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Wait for the second burst
    if (isWaitingForSecondBurst) {
      waitTimer += dt;
      if (waitTimer >= waitDuration) {
        // Second burst
        _createBurst();
        onBurstSound?.call();
        burstPhase = 2;
        isWaitingForSecondBurst = false;
      }
    }
  }

  void _createBurst() {
    for (int i = 0; i < 50; i++) {
      add(ConfettiParticle());
    }
  }
}

class ConfettiParticle extends RectangleComponent
    with HasGameReference<ConfettiGame> {
  late Vector2 velocity;
  late double rotationSpeed;
  late Color particleColor;
  late double initialSpeed;

  @override
  Future<void> onLoad() async {
    final random = Random();

    // Color
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    particleColor = colors[random.nextInt(colors.length)];

    // Size
    size = Vector2(8 + random.nextDouble() * 12, 8 + random.nextDouble() * 12);

    // Initial position
    position = Vector2(
      game.size.x * 0.5 + (random.nextDouble() - 0.5) * 100,
      game.size.y + size.y,
    );

    // Speed
    initialSpeed = 300 + random.nextDouble() * 200;
    velocity = Vector2((random.nextDouble() - 0.5) * 300, -initialSpeed);

    rotationSpeed = (random.nextDouble() - 0.5) * 10;
    paint.color = particleColor;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
    angle += rotationSpeed * dt;

    // Gravity
    velocity.y += 500 * dt;

    // Remove when out of screen
    if (position.y > game.size.y + size.y + 100 ||
        position.x < -size.x - 100 ||
        position.x > game.size.x + size.x + 100) {
      removeFromParent();
    }
  }
}

class ConfettiWidget extends ConsumerStatefulWidget {
  final Duration duration;
  final Widget child;

  const ConfettiWidget({
    super.key,
    this.duration = const Duration(seconds: 3),
    required this.child,
  });

  @override
  ConsumerState<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends ConsumerState<ConfettiWidget> {
  bool _showConfetti = false;
  late ConfettiGame _confettiGame;

  @override
  void initState() {
    super.initState();
    // Create once
    final sfx = ref.read(sfxProvider);
    _confettiGame = ConfettiGame(onBurstSound: () => sfx.confetti());
  }

  void _startConfetti() {
    setState(() => _showConfetti = true);
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Start confetti on first build
    if (!_showConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startConfetti());
    }

    return Stack(
      children: [
        widget.child,
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(child: GameWidget(game: _confettiGame)),
          ),
      ],
    );
  }
}
