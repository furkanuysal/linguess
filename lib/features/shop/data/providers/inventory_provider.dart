import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

// Provider to fetch owned item IDs
final inventoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final userInv = await repo.fetchFullInventory();
  return userInv;
});

// Provider for user stats stream (gold, level)
final userStatsShopProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final repo = ref.read(inventoryRepositoryProvider);
  return repo.userStatsStream();
});
