import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/repositories/shop_repository.dart';

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  return ref.watch(shopRepositoryProvider).fetchAllItems();
});

final shopRepositoryProvider = Provider((ref) => ShopRepository());
