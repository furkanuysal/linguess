import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopItemLockedOverlay extends StatelessWidget {
  final ShopItem item;
  const ShopItemLockedOverlay({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withValues(alpha: 0.35),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, size: 42, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  '${l10n.level}: ${item.requiredLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
