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

      // Add item to inventory
      tx.set(invRef, {
        'ownedAt': FieldValue.serverTimestamp(),
        'equipped': false,
        'type': itemData['type'] is ShopItemType
            ? (itemData['type'] as ShopItemType).nameString
            : (itemData['type'] ?? 'unknown'),
      });
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
}
