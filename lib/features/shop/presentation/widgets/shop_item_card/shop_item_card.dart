import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_card_body.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_dialog.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_locked_overlay.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopItemCard extends ConsumerWidget {
  const ShopItemCard({
    super.key,
    required this.item,
    this.onBuy,
    this.onEquip,
    this.onUnequip,
    this.isOwned = false,
    this.isEquipped = false,
    this.isLocked = false,
  });

  final ShopItem item;
  final VoidCallback? onBuy;
  final VoidCallback? onEquip;
  final VoidCallback? onUnequip;
  final bool isOwned;
  final bool isEquipped;
  final bool isLocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => showItemDetailsDialog(
        context,
        ref,
        item: item,
        onBuy: onBuy,
        onEquip: onEquip,
        onUnequip: onUnequip,
        isOwned: isOwned,
        isEquipped: isEquipped,
        isLocked: isLocked,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShopItemCardBody(
              item: item,
              isOwned: isOwned,
              isEquipped: isEquipped,
              isLocked: isLocked,
              onBuy: onBuy,
              onEquip: onEquip,
              onUnequip: onUnequip,
            ),
            if (isEquipped) _EquippedBadge(),
            if (isLocked) ShopItemLockedOverlay(item: item),
          ],
        ),
      ),
    );
  }
}

class _EquippedBadge extends StatelessWidget {
  const _EquippedBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      top: 6,
      right: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              l10n.equippedLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
