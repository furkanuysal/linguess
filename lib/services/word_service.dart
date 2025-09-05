import 'package:cloud_firestore/cloud_firestore.dart';

class WordService {
  final _col = FirebaseFirestore.instance.collection('words');

  Future<bool> exists(String id) async => (await _col.doc(id).get()).exists;

  Future<void> create(String id, Map<String, dynamic> data) =>
      _col.doc(id).set(data);

  Future<void> update(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);
}
