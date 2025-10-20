import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checks if a given category or level (or their combination) has at least 12 words.
/// Used for Time Attack mode validation.
final wordSufficiencyProvider = FutureProvider.family<bool, (String?, String?)>(
  (ref, params) async {
    final firestore = FirebaseFirestore.instance;
    final (categoryId, levelId) = params;

    // Insufficient if neither parameter is provided
    if (categoryId == null && levelId == null) return false;

    Query<Map<String, dynamic>> query = firestore.collection('words');

    // If both parameters are filled (category + level combination)
    if (categoryId != null && levelId != null) {
      query = query
          .where('category', isEqualTo: categoryId)
          .where('level', isEqualTo: levelId);
    } else if (categoryId != null) {
      // If only category is selected
      query = query.where('category', isEqualTo: categoryId);
    } else if (levelId != null) {
      // If only level is selected
      query = query.where('level', isEqualTo: levelId);
    }

    // Check if there are at least 12 words
    final snapshot = await query.limit(12).get();

    if (snapshot.metadata.isFromCache) {
      await Future.delayed(const Duration(milliseconds: 200));
      final fresh = await query
          .limit(12)
          .get(const GetOptions(source: Source.server));
      return fresh.docs.length >= 12;
    }

    return snapshot.docs.length >= 12;
  },
);
