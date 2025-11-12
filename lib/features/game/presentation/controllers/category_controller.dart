import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';
import 'package:linguess/features/shop/data/providers/inventory_provider.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

final categoryControllerProvider = Provider<CategoryController>((ref) {
  final shopItems = ref.watch(shopItemsProvider).value ?? [];
  final shopCategories = shopItems
      .where((e) => e.type == ShopItemType.category)
      .toList();
  final inventory = ref.watch(inventoryProvider).value ?? [];

  return CategoryController(ref, shopCategories, inventory);
});

class CategoryController {
  CategoryController(this.ref, this.shopCategories, this.inventory);

  final Ref ref;
  final List<ShopItem> shopCategories;
  final List<dynamic> inventory;

  bool isBuyable(String categoryId) {
    return shopCategories.any((s) => s.id == '${categoryId}_category');
  }

  bool isOwned(String categoryId) {
    return inventory.any((e) => e['id'] == '${categoryId}_category');
  }

  int getPrice(String categoryId) {
    final meta = shopCategories.firstWhere(
      (s) => s.id == '${categoryId}_category',
      orElse: () => ShopItem(
        id: '',
        type: ShopItemType.other,
        price: 0,
        requiredLevel: 1,
        rarity: '',
        iconUrl: '',
        translations: const {},
      ),
    );
    return meta.id.isEmpty ? 0 : meta.price;
  }

  int getRequiredLevel(String categoryId) {
    final meta = shopCategories.firstWhere(
      (s) => s.id == '${categoryId}_category',
      orElse: () => ShopItem(
        id: '',
        type: ShopItemType.other,
        price: 0,
        requiredLevel: 1,
        rarity: '',
        iconUrl: '',
        translations: const {},
      ),
    );
    return meta.id.isEmpty ? 1 : meta.requiredLevel;
  }

  Future<void> buyCategory(BuildContext context, String categoryId) async {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    if (!isSignedIn() || currentUser() == null) {
      _showSnack(context, l10n.signInToBuyItems, scheme.error);
      return;
    }

    final repo = ref.read(inventoryRepositoryProvider);

    try {
      await repo.buyItem('${categoryId}_category');
      ref.invalidate(inventoryProvider);
      ref.invalidate(userStatsShopProvider);
      if (!context.mounted) return;
      _showSnack(context, l10n.purchaseSuccessful, scheme.primary);
    } catch (e) {
      if (!context.mounted) return;

      final errorMsg = e.toString().toLowerCase();
      String message = l10n.errorOccurred;

      if (errorMsg.contains('not enough gold')) {
        message = l10n.insufficientGold;
      } else if (errorMsg.contains('level too low')) {
        final req = getRequiredLevel(categoryId);
        message = l10n.levelTooLow(req);
      } else if (errorMsg.contains('already owned')) {
        message = l10n.itemAlreadyOwned;
      }

      _showSnack(context, message, scheme.error);
    }
  }

  void _showSnack(BuildContext context, String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
