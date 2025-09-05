// lib/controllers/add_word_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/models/word_model.dart';
import 'package:linguess/services/word_service.dart';

final wordServiceProvider = Provider((ref) => WordService());

String slugify(String s) {
  return s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\\s]'), ' ')
      .replaceAll(RegExp(r'\\s+'), ' ')
      .trim();
}

class AddWordController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addOrUpdate({
    required String category,
    required String level,
    required Map<String, String> translations,
    required bool overwrite,
  }) async {
    state = const AsyncLoading();

    try {
      final en = (translations['en'] ?? '').trim();
      if (en.isEmpty) throw Exception('English is required');
      if (!['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].contains(level)) {
        throw Exception('Invalid level');
      }
      if (category.trim().isEmpty) throw Exception('Category is required');

      final id = slugify(en);
      final svc = ref.read(wordServiceProvider);
      final exists = await svc.exists(id);

      // remove empty strings
      final cleaned = <String, String>{
        for (final e in translations.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
      };

      final word = WordModel(
        id: id,
        category: category.trim(),
        level: level.trim(),
        translations: cleaned,
      );

      if (exists) {
        if (!overwrite) {
          throw Exception('This word already exists ($id)');
        }
        await svc.update(word.id, word.toUpdateJson());
      } else {
        await svc.create(word.id, word.toCreateJson());
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
