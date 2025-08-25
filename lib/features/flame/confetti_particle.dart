import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ConfettiGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // Create confetti particles
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
  int resetCount = 0;
  static const int maxResets = 1;

  @override
  Future<void> onLoad() async {
    final random = Random();

    // Random color
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

    // Random size
    size = Vector2(8 + random.nextDouble() * 12, 8 + random.nextDouble() * 12);

    // Starting position (from the bottom center of the screen)
    position = Vector2(
      game.size.x * 0.5 +
          (random.nextDouble() - 0.5) * 100, // Center with some spread
      game.size.y + size.y, // Start from bottom
    );

    // Initial upward velocity (explosion effect)
    initialSpeed = 300 + random.nextDouble() * 200;
    velocity = Vector2(
      (random.nextDouble() - 0.5) * 300, // Horizontal spread
      -initialSpeed, // Negative for upward movement
    );

    rotationSpeed = (random.nextDouble() - 0.5) * 10;
    paint.color = particleColor;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update position
    position += velocity * dt;

    // Update rotation
    angle += rotationSpeed * dt;

    // Gravity effect (pulls particles down)
    velocity.y += 500 * dt;

    // If particle goes off screen, reset it
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      if (resetCount < maxResets) {
        _resetParticle();
      } else {
        // Hide the particle (send it off-screen)
        position = Vector2(-1000, -1000);
        velocity = Vector2.zero();
      }
    }
  }

  void _resetParticle() {
    final random = Random();
    resetCount++;

    // Reset to bottom center
    position = Vector2(
      game.size.x * 0.5 + (random.nextDouble() - 0.5) * 100,
      game.size.y + size.y,
    );

    // Reset velocity for upward explosion
    initialSpeed = 300 + random.nextDouble() * 200;
    velocity = Vector2((random.nextDouble() - 0.5) * 300, -initialSpeed);
  }
}

class ConfettiWidget extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const ConfettiWidget({
    super.key,
    this.duration = const Duration(seconds: 4),
    required this.child,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _startConfetti();
  }

  void _startConfetti() {
    setState(() {
      _showConfetti = true;
    });

    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(child: GameWidget(game: ConfettiGame())),
          ),
      ],
    );
  }
}
