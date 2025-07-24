import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('index')
          .get();
      log('Kategori sayısı: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      log('Kategori çekme hatası: $e');
      return [];
    }
  }
}
