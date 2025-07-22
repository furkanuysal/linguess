import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/level_model.dart';

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
      print('Seviye sayısı: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LevelModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Seviye çekme hatası: $e');
      return [];
    }
  }
}
