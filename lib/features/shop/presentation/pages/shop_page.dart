import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shopItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ), // Todo: Localize title and use appropriate styling
      body: itemsAsync.when(
        data: (items) => GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            final userLevel = 8; // Todo: Fetch actual user level
            final ownedIds = [
              'silver_frame',
            ]; // Todo: Fetch actual owned item IDs

            return ShopItemCard(
              item: item,
              isLocked: userLevel < item.requiredLevel,
              isOwned: ownedIds.contains(item.id),
              onBuy: () {},
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')), // Todo: Localize
      ),
    );
  }
}
