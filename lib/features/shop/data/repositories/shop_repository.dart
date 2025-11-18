import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;
  ShopRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference<Map<String, dynamic>> get _shopRef =>
      _firestore.collection('shop');

  Future<List<ShopItem>> fetchAllItems() async {
    try {
      final snap = await _shopRef.orderBy('price').get();

      log('Shop fetch count: ${snap.docs.length}');

      return snap.docs.map((d) => ShopItem.fromMap(d.id, d.data())).toList();
    } catch (e, st) {
      log('Error fetching shop items: $e\n$st');
      return []; // Empty list on error to prevent app crash
    }
  }

  // CRUD Operations for Admin Panel
  // Stream (Live Tracking) - For Admin list
  Stream<List<ShopItem>> watchAllItems() {
    // Type based ordering
    return _shopRef.orderBy('type').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ShopItem.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Create
  Future<void> addItem(ShopItem item) async {
    try {
      // Using ShopItem ID as doc ID (set)
      await _shopRef.doc(item.id).set(item.toMap());
      log('Shop item added: ${item.id}');
    } catch (e) {
      log('Error adding shop item: $e');
      rethrow; // Rethrow to show error message in Admin UI
    }
  }

  // Update
  Future<void> updateItem(ShopItem item) async {
    try {
      await _shopRef.doc(item.id).update(item.toMap());
      log('Shop item updated: ${item.id}');
    } catch (e) {
      log('Error updating shop item: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteItem(String id) async {
    try {
      await _shopRef.doc(id).delete();
      log('Shop item deleted: $id');
    } catch (e) {
      log('Error deleting shop item: $e');
      rethrow;
    }
  }
}
