import "package:cloud_firestore/cloud_firestore.dart";
import '../models/word_model.dart';

class WordRepository {
  final FirebaseFirestore _firestore;

  WordRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<WordModel>> fetchWordsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('words')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => WordModel.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch words: $e');
    }
  }
}
