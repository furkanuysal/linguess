// lib/controllers/add_word_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/admin/data/services/word_service.dart';

final wordServiceProvider = Provider((ref) => WordAdminService());

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
    String? editId,
  }) async {
    state = const AsyncLoading();
    try {
      final en = (translations['en'] ?? '').trim();
      if (en.isEmpty) throw Exception('English is required');
      if (!['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].contains(level)) {
        throw Exception('Invalid level');
      }
      if (category.trim().isEmpty) throw Exception('Category is required');

      final svc = ref.read(wordServiceProvider);
      final cleaned = <String, String>{
        for (final e in translations.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
      };

      // id: in edit mode, use the existing doc id; otherwise, use slugify(en)
      final id = editId ?? slugify(en);

      if (editId != null) {
        // zorunlu update
        await svc.update(id, {
          'category': category.trim(),
          'level': level.trim(),
          'translations': cleaned,
        });
      } else {
        final exists = await svc.exists(id);
        if (exists && !overwrite) {
          throw Exception('This word already exists ($id)');
        }
        if (exists) {
          await svc.update(id, {
            'category': category.trim(),
            'level': level.trim(),
            'translations': cleaned,
          });
        } else {
          await svc.create(id, {
            'category': category.trim(),
            'level': level.trim(),
            'translations': cleaned,
          });
        }
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
