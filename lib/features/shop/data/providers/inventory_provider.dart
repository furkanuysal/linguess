import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/features/shop/data/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

// Returns the full inventory of the current user.
// If not signed in, returns an empty list without querying Firestore.
final inventoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = currentUser();

  if (!isSignedIn() || user == null) {
    return <Map<String, dynamic>>[];
  }

  final repo = ref.read(inventoryRepositoryProvider);
  try {
    final userInv = await repo.fetchFullInventory();
    return userInv;
  } catch (e) {
    return <Map<String, dynamic>>[];
  }
});

// Returns user stats like gold and level for the shop page.
// If not signed in, returns default stats without querying Firestore.
final userStatsShopProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = currentUser();

  if (!isSignedIn() || user == null) {
    return Stream.value({'gold': 0, 'level': 0});
  }

  final repo = ref.read(inventoryRepositoryProvider);
  try {
    return repo.userStatsStream();
  } catch (e) {
    return Stream.value({'gold': 0, 'level': 0});
  }
});
