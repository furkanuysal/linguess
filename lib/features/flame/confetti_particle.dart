import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/sfx/sfx_service.dart'; // sfxProvider

class ConfettiGame extends FlameGame {
  ConfettiGame({this.onBurstSound});

  /// Sound to be played on each burst wave
  final VoidCallback? onBurstSound;

  DateTime? _lastBurstSoundAt;
  final Duration _cooldown = const Duration(milliseconds: 180);

  @override
  Color backgroundColor() => Colors.transparent;

  /// Called when a particle makes a "base burst"
  void playBurstSoundThrottled() {
    final now = DateTime.now();
    if (_lastBurstSoundAt == null ||
        now.difference(_lastBurstSoundAt!) > _cooldown) {
      _lastBurstSoundAt = now;
      onBurstSound?.call();
    }
  }

  @override
  Future<void> onLoad() async {
    // First burst sound
    playBurstSoundThrottled();

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

    // color
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

    // size
    size = Vector2(8 + random.nextDouble() * 12, 8 + random.nextDouble() * 12);

    // initial position (around the base center)
    position = Vector2(
      game.size.x * 0.5 + (random.nextDouble() - 0.5) * 100,
      game.size.y + size.y,
    );

    // initial launch speed
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

    // gravity
    velocity.y += 500 * dt;

    // reset if it leaves the screen
    if (position.y > game.size.y + size.y ||
        position.x < -size.x ||
        position.x > game.size.x + size.x) {
      if (resetCount < maxResets) {
        _resetParticle(); // launch again from the base
        game.playBurstSoundThrottled(); // request sound on each burst wave
      } else {
        // "finish"
        position = Vector2(-1000, -1000);
        velocity = Vector2.zero();
      }
    }
  }

  void _resetParticle() {
    final random = Random();
    resetCount++;

    position = Vector2(
      game.size.x * 0.5 + (random.nextDouble() - 0.5) * 100,
      game.size.y + size.y,
    );

    initialSpeed = 300 + random.nextDouble() * 200;
    velocity = Vector2((random.nextDouble() - 0.5) * 300, -initialSpeed);
  }
}

class ConfettiWidget extends ConsumerStatefulWidget {
  final Duration duration;
  final Widget child;

  const ConfettiWidget({
    super.key,
    this.duration = const Duration(seconds: 4),
    required this.child,
  });

  @override
  ConsumerState<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends ConsumerState<ConfettiWidget> {
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    // sfx preload
    ref.read(sfxProvider);
    _startConfetti();
  }

  void _startConfetti() {
    setState(() => _showConfetti = true);
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sfx = ref.read(sfxProvider);

    return Stack(
      children: [
        widget.child,
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: GameWidget(
                game: ConfettiGame(
                  onBurstSound: () =>
                      sfx.confetti(), // first + subsequent bursts
                ),
              ),
            ),
          ),
      ],
    );
  }
}
