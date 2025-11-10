import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_card_body.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_dialog.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_locked_overlay.dart';

class ShopItemCard extends ConsumerWidget {
  const ShopItemCard({
    super.key,
    required this.item,
    this.onBuy,
    this.onEquip,
    this.isOwned = false,
    this.isEquipped = false,
    this.isLocked = false,
  });

  final ShopItem item;
  final VoidCallback? onBuy;
  final VoidCallback? onEquip;
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
            ),
            if (isLocked) ShopItemLockedOverlay(item: item),
          ],
        ),
      ),
    );
  }
}
