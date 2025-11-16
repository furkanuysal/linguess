import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/providers/inventory_provider.dart';
import 'package:linguess/features/auth/presentation/providers/user_equipped_provider.dart';

void invalidateShopProviders(WidgetRef ref) {
  ref.invalidate(inventoryProvider); // Refresh inventory
  ref.invalidate(userStatsShopProvider); // Refresh gold and level
  ref.invalidate(avatarImageProvider); // Avatar may change
  ref.invalidate(avatarFrameProvider); // Frame may change
  ref.invalidate(backgroundImageProvider); // Background may change
}
