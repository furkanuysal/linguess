import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/auth/presentation/providers/user_equipped_provider.dart';
import 'package:linguess/core/utils/auth_utils.dart';

class EquippedAvatar extends ConsumerWidget {
  const EquippedAvatar({
    super.key,
    this.size = 64,
    this.iconSize = 30,
    this.showRingFallback = false,
    this.borderWidth = 2,
    this.heroTag,
  });

  // Overall avatar container size (width=height)
  final double size;

  // Size of the fallback person icon
  final double iconSize;

  // If true → draw colored ring when frame is missing (Home)
  final bool showRingFallback;

  // Border thickness for fallback ring
  final double borderWidth;

  // Hero tag for avatar transitions
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarAsync = ref.watch(avatarImageProvider);
    final frameAsync = ref.watch(avatarFrameProvider);
    final scheme = Theme.of(context).colorScheme;
    final user = currentUser();

    final defaultRingColor = user == null
        ? scheme.surfaceContainerHighest
        : scheme.primary;

    Widget placeholder() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: showRingFallback
            ? Border.all(color: defaultRingColor, width: borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline,
        color: scheme.onSurface,
        size: iconSize,
      ),
    );

    Widget loader() => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: showRingFallback
            ? Border.all(color: defaultRingColor, width: borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );

    return frameAsync.when(
      loading: loader,
      error: (_, _) => placeholder(),
      data: (frameUrl) {
        final hasFrame = frameUrl != null && frameUrl.isNotEmpty;
        DecorationImage? frameImage;

        if (hasFrame) {
          frameImage = DecorationImage(
            image: frameUrl.startsWith('http')
                ? NetworkImage(frameUrl)
                : AssetImage(frameUrl) as ImageProvider,
            fit: BoxFit.cover,
          );
        }
        final double dynamicPadding = hasFrame ? size * 0.18 : 0;

        final avatarWidget = Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(dynamicPadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: frameImage,
            border: !hasFrame && showRingFallback
                ? Border.all(color: defaultRingColor, width: borderWidth)
                : null,
          ),
          child: avatarAsync.when(
            loading: loader,
            error: (_, _) => placeholder(),
            data: (avatarUrl) {
              final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
              ImageProvider? avatarImage;

              if (hasAvatar) {
                avatarImage = avatarUrl.startsWith('http')
                    ? NetworkImage(avatarUrl)
                    : AssetImage(avatarUrl) as ImageProvider;
              }

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  image: avatarImage != null
                      ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                      : null,
                ),
                alignment: Alignment.center,
                child: avatarImage == null
                    ? Icon(
                        Icons.person_outline,
                        color: scheme.onSurface,
                        size: iconSize,
                      )
                    : null,
              );
            },
          ),
        );
        return heroTag != null
            ? Hero(tag: heroTag!, child: avatarWidget)
            : avatarWidget;
      },
    );
  }
}
