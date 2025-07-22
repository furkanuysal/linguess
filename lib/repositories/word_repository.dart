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

      final words = snapshot.docs
          .map((doc) => WordModel.fromJson(doc.id, doc.data()))
          .toList();

      words.shuffle(); // Rastgele sıralamak için

      return words;
    } catch (e) {
      throw Exception('Failed to fetch words by category: $e');
    }
  }

  Future<List<WordModel>> fetchWordsByLevel(String level) async {
    try {
      final snapshot = await _firestore
          .collection('words')
          .where('level', isEqualTo: level)
          .get();

      final words = snapshot.docs
          .map((doc) => WordModel.fromJson(doc.id, doc.data()))
          .toList();

      words.shuffle(); // Rastgele sıralamak için

      return words;
    } catch (e) {
      throw Exception('Failed to fetch words by level: $e');
    }
  }
}
