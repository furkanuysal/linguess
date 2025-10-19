import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wordAvailabilityProvider = FutureProvider.family<bool, (String?, String?)>((
  ref,
  params,
) async {
  final firestore = FirebaseFirestore.instance;
  final (categoryId, levelId) = params;

  // If both categoryId and levelId are null, all words are available
  if (categoryId == null && levelId == null) return true;

  // dynamic query
  Query<Map<String, dynamic>> query = firestore.collection('words');

  if (categoryId != null) {
    query = query.where('category', isEqualTo: categoryId);
  }
  if (levelId != null) {
    query = query.where('level', isEqualTo: levelId);
  }

  // Limit added for quick scanning
  final snapshot = await query.limit(1).get();

  // Short delay for quick refresh (e.g., can update from server after Firestore cache)
  // This way, "newly added word" can be detected in the 2nd fetch
  if (snapshot.metadata.isFromCache) {
    await Future.delayed(const Duration(milliseconds: 200));
    final fresh = await query
        .limit(1)
        .get(const GetOptions(source: Source.server));
    return fresh.docs.isNotEmpty;
  }

  return snapshot.docs.isNotEmpty;
});
