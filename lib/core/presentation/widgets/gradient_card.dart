import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  const GradientCard({super.key, required this.child, this.onTap, this.border});
  final Widget child;
  final VoidCallback? onTap;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.surface, scheme.surfaceContainerHigh],
          ),
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}
