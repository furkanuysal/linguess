import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ShopItem>> fetchAllItems() async {
    final snap = await _firestore.collection('shop').get();
    return snap.docs.map((d) => ShopItem.fromMap(d.id, d.data())).toList();
  }
}
