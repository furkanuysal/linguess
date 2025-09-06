import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/admin/data/services/word_service.dart';
import 'package:linguess/features/game/data/models/word_model.dart';

final wordServiceProvider = Provider((ref) => WordAdminService());

final wordByIdProvider = FutureProvider.family<WordModel?, String>((
  ref,
  id,
) async {
  final svc = ref.read(wordServiceProvider);
  return svc.getById(id);
});
