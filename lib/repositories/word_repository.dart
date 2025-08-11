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

  Future<WordModel?> fetchWordById(String wordId) async {
    try {
      final doc = await _firestore.collection('words').doc(wordId).get();

      if (!doc.exists) return null;

      return WordModel.fromJson(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch word by ID: $e');
    }
  }

  Future<List<WordModel>> fetchWordsByIds(List<String> wordIds) async {
    if (wordIds.isEmpty) return [];
    const chunkSize = 10;
    final List<WordModel> result = [];
    for (int i = 0; i < wordIds.length; i += chunkSize) {
      final chunk = wordIds.sublist(
        i,
        i + chunkSize > wordIds.length ? wordIds.length : i + chunkSize,
      );
      final snapshot = await _firestore
          .collection('words')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      final words = snapshot.docs
          .map((doc) => WordModel.fromJson(doc.id, doc.data()))
          .toList();

      result.addAll(words);
    }
    return result;
  }

  Future<WordModel> fetchRandomWord() async {
    final snapshot = await _firestore
        .collection('words')
        .limit(100) // Limit to 100 for performance
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No words found');
    }

    final list = snapshot.docs
        .map((doc) => WordModel.fromJson(doc.id, doc.data()))
        .toList();
    list.shuffle();
    return list.first;
  }
}
