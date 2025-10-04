import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sfx_service.dart';

class SfxElevatedButton extends ConsumerWidget {
  const SfxElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sfx = ref.watch(sfxProvider);
    return ElevatedButton(
      onPressed: () {
        sfx.select();
        onPressed();
      },
      child: child,
    );
  }
}

class SfxIconButton extends ConsumerWidget {
  const SfxIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.onLongPress,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sfx = ref.watch(sfxProvider);
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        sfx.select();
        onPressed();
      },
      onLongPress: onLongPress,
      icon: icon,
    );
  }
}
