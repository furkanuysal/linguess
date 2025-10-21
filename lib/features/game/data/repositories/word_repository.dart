import 'dart:math';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/foundation.dart';
import 'package:linguess/features/game/data/models/word_model.dart';

class WordRepository {
  final FirebaseFirestore _firestore;

  WordRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<WordModel?> fetchRandomWord() async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');

    var snap = await ref
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      snap = await ref
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(1)
          .get();
    }

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordByCategory(String category) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');

    var snap = await ref
        .where('category', isEqualTo: category)
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      snap = await ref
          .where('category', isEqualTo: category)
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(1)
          .get();
    }

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordByLevel(String level) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');

    var snap = await ref
        .where('level', isEqualTo: level)
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      snap = await ref
          .where('level', isEqualTo: level)
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(1)
          .get();
    }

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordByCategoryAndLevel({
    required String category,
    required String level,
    required List<String> learnedIds,
    required bool repeatLearnedWords,
  }) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');

    Query<Map<String, dynamic>> query = ref
        .where('category', isEqualTo: category)
        .where('level', isEqualTo: level);

    if (!repeatLearnedWords &&
        learnedIds.isNotEmpty &&
        learnedIds.length <= 10) {
      query = query.where(FieldPath.documentId, whereNotIn: learnedIds);
    }

    var snap = await query
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(10)
        .get();

    if (snap.docs.isEmpty) {
      snap = await query
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(10)
          .get();
    }

    var docs = snap.docs;
    if (!repeatLearnedWords && learnedIds.length > 10) {
      docs = docs.where((d) => !learnedIds.contains(d.id)).toList();
    }

    if (docs.isEmpty) return null;

    docs.shuffle();
    final doc = docs.first;
    return WordModel.fromJson(doc.id, doc.data());
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

  Future<WordModel?> fetchRandomWordFiltered(List<String> learnedIds) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');

    Query<Map<String, dynamic>> query = ref;
    if (learnedIds.isNotEmpty && learnedIds.length <= 10) {
      query = query.where(FieldPath.documentId, whereNotIn: learnedIds);
    }

    var snap = await query
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(10)
        .get();

    if (snap.docs.isEmpty) {
      snap = await query
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(10)
          .get();
    }

    var docs = snap.docs;
    if (learnedIds.length > 10) {
      docs = docs.where((d) => !learnedIds.contains(d.id)).toList();
    }

    if (docs.isEmpty) return null;

    docs.shuffle();
    final doc = docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordByCategoryFiltered({
    required String category,
    required List<String> learnedIds,
  }) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');
    Query<Map<String, dynamic>> query = ref.where(
      'category',
      isEqualTo: category,
    );

    if (learnedIds.isNotEmpty && learnedIds.length <= 10) {
      query = query.where(FieldPath.documentId, whereNotIn: learnedIds);
    }

    var snap = await query
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(10)
        .get();

    if (snap.docs.isEmpty) {
      snap = await query
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(10)
          .get();
    }

    var docs = snap.docs;
    if (learnedIds.length > 10) {
      docs = docs.where((d) => !learnedIds.contains(d.id)).toList();
    }

    if (docs.isEmpty) return null;

    docs.shuffle();
    final doc = docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordByLevelFiltered({
    required String level,
    required List<String> learnedIds,
  }) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');
    Query<Map<String, dynamic>> query = ref.where('level', isEqualTo: level);

    if (learnedIds.isNotEmpty && learnedIds.length <= 10) {
      query = query.where(FieldPath.documentId, whereNotIn: learnedIds);
    }

    var snap = await query
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(10)
        .get();

    if (snap.docs.isEmpty) {
      snap = await query
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(10)
          .get();
    }

    var docs = snap.docs;
    if (learnedIds.length > 10) {
      docs = docs.where((d) => !learnedIds.contains(d.id)).toList();
    }

    if (docs.isEmpty) return null;

    docs.shuffle();
    final doc = docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordByCategoryAndLevelFiltered({
    required String category,
    required String level,
    required List<String> learnedIds,
  }) async {
    final r = Random().nextDouble();
    final ref = _firestore.collection('words');

    Query<Map<String, dynamic>> query = ref
        .where('category', isEqualTo: category)
        .where('level', isEqualTo: level);

    if (learnedIds.isNotEmpty && learnedIds.length <= 10) {
      query = query.where(FieldPath.documentId, whereNotIn: learnedIds);
    }

    var snap = await query
        .where('random', isGreaterThanOrEqualTo: r)
        .orderBy('random')
        .limit(10)
        .get();

    if (snap.docs.isEmpty) {
      snap = await query
          .where('random', isLessThanOrEqualTo: r)
          .orderBy('random', descending: true)
          .limit(10)
          .get();
    }

    var docs = snap.docs;
    if (learnedIds.length > 10) {
      docs = docs.where((d) => !learnedIds.contains(d.id)).toList();
    }

    if (docs.isEmpty) return null;

    docs.shuffle();
    final doc = docs.first;
    return WordModel.fromJson(doc.id, doc.data());
  }

  Future<WordModel?> fetchRandomWordWithSettings({
    String? category,
    String? level,
    required bool repeatLearnedWords,
    required List<String> learnedIds,
  }) async {
    if (category != null && level != null) {
      if (repeatLearnedWords) {
        return fetchRandomWordByCategoryAndLevel(
          category: category,
          level: level,
          learnedIds: learnedIds,
          repeatLearnedWords: repeatLearnedWords,
        );
      } else {
        return fetchRandomWordByCategoryAndLevelFiltered(
          category: category,
          level: level,
          learnedIds: learnedIds,
        );
      }
    }
    if (repeatLearnedWords) {
      if (category != null) return fetchRandomWordByCategory(category);
      if (level != null) return fetchRandomWordByLevel(level);
      return fetchRandomWord();
    } else {
      if (category != null) {
        return fetchRandomWordByCategoryFiltered(
          category: category,
          learnedIds: learnedIds,
        );
      }
      if (level != null) {
        return fetchRandomWordByLevelFiltered(
          level: level,
          learnedIds: learnedIds,
        );
      }
      return fetchRandomWordFiltered(learnedIds);
    }
  }

  Future<List<WordModel>> fetchWordsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('words')
          .where('category', isEqualTo: category)
          .get();

      final words = snapshot.docs
          .map((doc) => WordModel.fromJson(doc.id, doc.data()))
          .toList();

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

      return words;
    } catch (e) {
      throw Exception('Failed to fetch words by level: $e');
    }
  }

  // Fetches a batch of random words for Time Attack mode.
  // - Supports optional category and level filters.
  // - Excludes already used word IDs (to avoid repeats).
  // - Returns up to [limit] words (or fewer if not enough available).
  Future<List<WordModel>> fetchBatchForTimeAttack({
    String? category,
    String? level,
    int limit = 25,
    List<String> excludeIds = const [],
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('words');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (level != null && level.isNotEmpty) {
        query = query.where('level', isEqualTo: level);
      }

      // Random order
      query = query.orderBy('random');

      // Getting extra to account for exclusions
      final snap = await query.limit(limit * 2).get();

      if (snap.docs.isEmpty) {
        debugPrint(
          'No words found for TimeAttack (cat=$category, level=$level)',
        );
        return [];
      }

      // Convert to models
      final all = snap.docs
          .map((d) => WordModel.fromJson(d.id, d.data()))
          .toList();

      // Exclude used IDs
      final filtered = all.where((w) => !excludeIds.contains(w.id)).toList();

      // If there are extra items, shuffle and take up to the limit
      filtered.shuffle();
      final result = filtered.take(limit).toList();

      if (result.length < limit) {
        debugPrint(
          'TimeAttack batch smaller than limit (${result.length}/$limit)',
        );
      }

      return result;
    } catch (e, st) {
      debugPrint('fetchBatchForTimeAttack failed: $e\n$st');
      return [];
    }
  }
}
