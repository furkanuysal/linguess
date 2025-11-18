import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/repositories/shop_repository.dart';

final shopRepositoryProvider = Provider((ref) => ShopRepository());

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  return ref.watch(shopRepositoryProvider).fetchAllItems();
});

// Admin Provider (Stream)
final adminShopListProvider = StreamProvider<List<ShopItem>>((ref) {
  return ref.watch(shopRepositoryProvider).watchAllItems();
});
