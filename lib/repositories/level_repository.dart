import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level_model.dart';
import 'dart:developer';

class LevelRepository {
  final FirebaseFirestore _firestore;

  LevelRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<LevelModel>> fetchLevels() async {
    try {
      final snapshot = await _firestore
          .collection('levels')
          .orderBy('index')
          .get();
      log('Seviye sayısı: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LevelModel.fromJson(data);
      }).toList();
    } catch (e) {
      log('Seviye çekme hatası: $e');
      return [];
    }
  }
}
