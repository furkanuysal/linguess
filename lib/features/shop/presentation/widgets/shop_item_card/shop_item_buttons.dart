import 'package:flutter/material.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopItemButtons {
  static Widget buildBottomSection(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n, {
    required bool isOwned,
    required bool isEquipped,
    required int price,
    VoidCallback? onBuy,
    VoidCallback? onEquip,
    VoidCallback? onUnequip,
    bool isHighRarity = false,
    ShopItemType? itemType,
  }) {
    final isCategory = itemType == ShopItemType.category;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: isOwned
          ? (isCategory
                ? _ownedButton(scheme, l10n)
                : (isEquipped
                      ? _unequipButton(scheme, l10n, onUnequip)
                      : _equipButton(scheme, l10n, onEquip)))
          : _buyButton(scheme, isHighRarity, onBuy, price),
    );
  }

  static Widget _ownedButton(ColorScheme scheme, AppLocalizations l10n) {
    return ElevatedButton.icon(
      key: const ValueKey('owned'),
      onPressed: null,
      icon: const Icon(Icons.check_rounded, size: 18),
      label: Text(
        l10n.ownedLabel,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary.withValues(alpha: 0.3),
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget _unequipButton(
    ColorScheme scheme,
    AppLocalizations l10n,
    VoidCallback? onUnequip,
  ) {
    return ElevatedButton.icon(
      key: const ValueKey('unequip'),
      onPressed: onUnequip,
      icon: const Icon(Icons.close_rounded, size: 18),
      label: Text(
        l10n.unequipLabel,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary.withValues(alpha: 0.4),
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget _equipButton(
    ColorScheme scheme,
    AppLocalizations l10n,
    VoidCallback? onEquip,
  ) {
    return ElevatedButton.icon(
      key: const ValueKey('equip'),
      onPressed: onEquip,
      icon: const Icon(Icons.play_circle_fill, size: 18),
      label: Text(
        l10n.equipLabel,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget _buyButton(
    ColorScheme scheme,
    bool isHighRarity,
    VoidCallback? onBuy,
    int price,
  ) {
    return Container(
      key: const ValueKey('buy'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isHighRarity
            ? const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isHighRarity ? null : Colors.amber.shade600,
      ),
      child: TextButton.icon(
        onPressed: onBuy,
        icon: const Icon(
          Icons.monetization_on_rounded,
          size: 20,
          color: Colors.black87,
        ),
        label: Text(
          '$price',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.black.withValues(alpha: 0.9),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
