import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/game/data/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // READ (game side)
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('index')
          .get();

      log('Category count: ${snapshot.docs.length}');

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e, st) {
      log('Error fetching categories: $e\n$st');
      return [];
    }
  }

  // Stream categories (for admin side)
  Stream<List<CategoryModel>> streamCategories() {
    return _firestore.collection('categories').orderBy('index').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.id, doc.data()))
            .toList();
      },
    );
  }

  // CRUD (admin side)
  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .set(category.toJson());
      log('Category added: ${category.id}');
    } catch (e) {
      log('Error adding category: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toJson());
      log('Category updated: ${category.id}');
    } catch (e) {
      log('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      log('Category deleted: $categoryId');
    } catch (e) {
      log('Error deleting category: $e');
    }
  }

  Future<int> nextIndex() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('index', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final lastIndex = snapshot.docs.first.data()['index'] as int;
        return lastIndex + 1;
      }
      return 0;
    } catch (e) {
      log('Error fetching next index: $e');
      return 0;
    }
  }

  Future<void> swapIndices({
    required String idA,
    required int indexA,
    required String idB,
    required int indexB,
  }) async {
    final batch = _firestore.batch();
    final col = _firestore.collection('categories');
    batch.update(col.doc(idA), {'index': indexB});
    batch.update(col.doc(idB), {'index': indexA});
    await batch.commit();
  }
}
