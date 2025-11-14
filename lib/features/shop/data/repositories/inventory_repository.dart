import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';

class InventoryRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // Fetch full inventory
  Future<List<Map<String, dynamic>>> fetchFullInventory() async {
    final snap = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('inventory')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'type': data['type'] ?? '',
        'equipped': data['equipped'] ?? false,

        // Booster specific fields
        if (data['type'] == ShopItemType.xpBoost.nameString ||
            data['type'] == ShopItemType.goldBoost.nameString) ...{
          'remainingUses': data['remainingUses'] ?? 0,
          'multiplier': data['multiplier'] ?? 1.0,
        },
      };
    }).toList();
  }

  // User stats stream (gold, level)
  Stream<Map<String, dynamic>> userStatsStream() {
    final userRef = _firestore.collection('users').doc(_uid);
    final levelRef = userRef.collection('stats').doc('leveling');

    final userStream = userRef.snapshots();
    final levelStream = levelRef.snapshots();

    // Return combined stream
    return userStream.asyncMap((userSnap) async {
      final gold = (userSnap.data()?['gold'] ?? 0) as int;
      final levelSnap = await levelStream.first;
      final level = (levelSnap.data()?['level'] ?? 1) as int;
      return {'gold': gold, 'level': level};
    });
  }

  // Buy item — Transaction: deduct gold + add to inventory
  Future<void> buyItem(String itemId) async {
    final userRef = _firestore.collection('users').doc(_uid);
    final levelRef = userRef.collection('stats').doc('leveling');
    final itemRef = _firestore.collection('shop').doc(itemId);
    final invRef = userRef.collection('inventory').doc(itemId);

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final levelSnap = await tx.get(levelRef);
      final itemSnap = await tx.get(itemRef);
      final invSnap = await tx.get(invRef);

      if (!userSnap.exists) throw Exception('User not found');
      if (!levelSnap.exists) throw Exception('Level stats not found');
      if (!itemSnap.exists) throw Exception('Item not found');
      if (invSnap.exists) throw Exception('Item already owned');

      final userData = userSnap.data()!;
      final levelData = levelSnap.data()!;
      final itemData = itemSnap.data()!;

      final int userGold = userData['gold'] ?? 0;
      final int userLevel = levelData['level'] ?? 1;
      final int price = itemData['price'] ?? 0;
      final int requiredLevel = itemData['requiredLevel'] ?? 1;

      if (userLevel < requiredLevel) {
        throw Exception('Level too low');
      }
      if (userGold < price) {
        throw Exception('Not enough gold');
      }

      // Buy item: deduct gold
      tx.update(userRef, {'gold': userGold - price});

      // Booster item type handling

      final String typeString = itemData['type'] is ShopItemType
          ? (itemData['type'] as ShopItemType).nameString
          : (itemData['type']?.toString() ?? 'unknown');

      final bool isBooster =
          typeString == ShopItemType.xpBoost.nameString ||
          typeString == ShopItemType.goldBoost.nameString;

      // Fetch booster specific fields
      final int baseUses = itemData['baseUses'] ?? 0;
      // Fetch booster multiplier
      final double baseMultiplier = (itemData['baseMultiplier'] ?? 1.0)
          .toDouble();

      // Inventory payload
      final Map<String, dynamic> invPayload = {
        'ownedAt': FieldValue.serverTimestamp(),
        'equipped': false,
        'type': typeString,
      };

      // Add booster specific fields
      if (isBooster) {
        invPayload['remainingUses'] = baseUses;
        invPayload['multiplier'] = baseMultiplier;
      }

      // Save inventory item
      tx.set(invRef, invPayload);
    });
  }

  // Equip item (Unequip others of same type)
  Future<void> equipItem(String itemId, ShopItemType type) async {
    final userInv = _firestore
        .collection('users')
        .doc(_uid)
        .collection('inventory');

    // Get all items of the same type
    final sameTypeSnap = await userInv
        .where('type', isEqualTo: type.nameString)
        .get();

    await _firestore.runTransaction((tx) async {
      // Unequip all items of the same type
      for (final doc in sameTypeSnap.docs) {
        tx.update(doc.reference, {'equipped': false});
      }

      // Equip the newly selected item
      final itemRef = userInv.doc(itemId);
      tx.update(itemRef, {'equipped': true});
    });
  }

  // Unequip item
  Future<void> unequipItem(String itemId) async {
    final ref = _firestore
        .collection('users')
        .doc(_uid)
        .collection('inventory')
        .doc(itemId);

    await ref.update({'equipped': false});
  }

  // Fetch equipped item URL
  Future<String?> fetchEquippedItemUrl(ShopItemType type) async {
    final userInv = _firestore
        .collection('users')
        .doc(_uid)
        .collection('inventory');

    // Find equipped item by type (e.g. avatar, frame, badge, etc.)
    final invSnap = await userInv
        .where('type', isEqualTo: type.nameString)
        .where('equipped', isEqualTo: true)
        .limit(1)
        .get();

    if (invSnap.docs.isEmpty) return null;

    final equippedId = invSnap.docs.first.id;
    final shopSnap = await _firestore.collection('shop').doc(equippedId).get();

    if (!shopSnap.exists) return null;

    final data = shopSnap.data()!;
    return data['iconUrl'] ?? data['url'] ?? data['asset'];
  }

  // Consume 1 use of a booster. If it reaches 0 → delete the booster.
  Future<void> consumeBoosterUse(String boosterId) async {
    final boosterRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('inventory')
        .doc(boosterId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(boosterRef);

      if (!snap.exists) {
        throw Exception('Booster not found');
      }

      final data = snap.data()!;
      final int remaining = (data['remainingUses'] ?? 0).toInt();

      if (remaining <= 0) {
        // Already empty or invalid — ensure deletion
        tx.delete(boosterRef);
        return;
      }

      final int next = remaining - 1;

      if (next <= 0) {
        // No uses left → delete booster
        tx.delete(boosterRef);
      } else {
        // Update remaining uses
        tx.update(boosterRef, {'remainingUses': next});
      }
    });
  }
}
