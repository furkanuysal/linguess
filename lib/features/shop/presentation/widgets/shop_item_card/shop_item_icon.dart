import 'package:flutter/material.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';

// Icon widget for shop items supporting Material Icons, network images, and asset images.
class ShopItemIcon extends StatelessWidget {
  const ShopItemIcon({
    super.key,
    required this.item,
    required this.scheme,
    this.size = 60,
    this.borderRadius = 12,
  });

  final ShopItem item;
  final ColorScheme scheme;

  // Icon size
  final double size;

  // Border radius for the image
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconUrl = item.iconUrl.trim();

    // Material Icon codePoint
    if (iconUrl.startsWith('0x')) {
      try {
        final codePoint = int.parse(iconUrl);
        return Center(
          child: Icon(
            IconData(codePoint, fontFamily: 'MaterialIcons'),
            size: size,
            color: scheme.primary,
          ),
        );
      } catch (_) {
        return _fallbackIcon();
      }
    }

    // Network image
    if (iconUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          iconUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _fallbackIcon(),
        ),
      );
    }

    // Asset image
    if (iconUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          iconUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _fallbackIcon(),
        ),
      );
    }

    // Fallback
    return _fallbackIcon();
  }

  Widget _fallbackIcon() => Center(
    child: Icon(
      Icons.category_rounded,
      size: size * 0.9,
      color: scheme.onSurfaceVariant,
    ),
  );
}
