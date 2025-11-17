import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/shop/data/providers/inventory_provider.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';

// Provider to get currently active boosters from the user's inventory
final activeBoostersProvider = Provider<ActiveBoosters?>((ref) {
  final invAsync = ref.watch(inventoryProvider);

  final inventory = invAsync.value;
  if (inventory == null) return null;

  Map<String, dynamic>? xp;
  Map<String, dynamic>? gold;

  for (final item in inventory) {
    final type = item['type']?.toString() ?? '';

    if (item['equipped'] != true) continue;

    if (type == ShopItemType.xpBoost.nameString) {
      xp = item;
    } else if (type == ShopItemType.goldBoost.nameString) {
      gold = item;
    }
  }

  return ActiveBoosters(
    xpBooster: xp != null
        ? BoosterData(
            id: xp['id'],
            multiplier: (xp['multiplier'] ?? 1.0).toDouble(),
            remaining: (xp['remainingUses'] ?? 0).toInt(),
          )
        : null,
    goldBooster: gold != null
        ? BoosterData(
            id: gold['id'],
            multiplier: (gold['multiplier'] ?? 1.0).toDouble(),
            remaining: (gold['remainingUses'] ?? 0).toInt(),
          )
        : null,
  );
});

class ActiveBoosters {
  final BoosterData? xpBooster;
  final BoosterData? goldBooster;

  ActiveBoosters({this.xpBooster, this.goldBooster});
}

class BoosterData {
  final String id;
  final double multiplier;
  final int remaining;

  BoosterData({
    required this.id,
    required this.multiplier,
    required this.remaining,
  });
}

final applyBoosterProvider =
    Provider<Future<int> Function(int base, BoosterData?)>((ref) {
      return (int base, BoosterData? booster) async {
        if (booster == null) return base;

        final boosted = (base * booster.multiplier).round();

        // Consume one use
        await ref
            .read(inventoryRepositoryProvider)
            .consumeBoosterUse(booster.id);

        ref.invalidate(inventoryProvider);
        ref.invalidate(activeBoostersProvider);

        return boosted;
      };
    });

// XP Booster Applier
final applyXpBoosterProvider = Provider<Future<int> Function(int baseXp)>((
  ref,
) {
  final apply = ref.read(applyBoosterProvider);

  return (int baseXp) async {
    final boosters = ref.read(activeBoostersProvider);
    return apply(baseXp, boosters?.xpBooster);
  };
});

// Gold Booster Applier
final applyGoldBoosterProvider = Provider<Future<int> Function(int baseGold)>((
  ref,
) {
  final apply = ref.read(applyBoosterProvider);

  return (int baseGold) async {
    final boosters = ref.read(activeBoostersProvider);
    return apply(baseGold, boosters?.goldBooster);
  };
});
