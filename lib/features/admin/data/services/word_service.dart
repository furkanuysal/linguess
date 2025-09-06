import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/game/data/models/word_model.dart';

class WordAdminService {
  final _col = FirebaseFirestore.instance.collection('words');

  Future<bool> exists(String id) async => (await _col.doc(id).get()).exists;

  Future<void> create(String id, Map<String, dynamic> data) =>
      _col.doc(id).set(data);

  Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<WordModel?> getById(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    return WordModel.fromJson(snap.id, data);
  }

  // Simple listing
  Query<Map<String, dynamic>> query({String? category, String? level}) {
    Query<Map<String, dynamic>> q = _col;
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    if (level != null && level.isNotEmpty) {
      q = q.where('level', isEqualTo: level);
    }
    return q;
  }
}
