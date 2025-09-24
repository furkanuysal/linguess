// lib/controllers/add_word_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/utils/slugify.dart';
import 'package:linguess/features/admin/data/services/word_service.dart';

final wordServiceProvider = Provider((ref) => WordAdminService());

class AddWordController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addOrUpdate({
    required String category,
    required String level,
    required Map<String, Map<String, String?>> locales,
    required bool overwrite,
    String? editId,
  }) async {
    state = const AsyncLoading();
    try {
      final enMap = locales['en'] ?? {};
      final enTerm = (enMap['term'] ?? '').trim();
      if (enTerm.isEmpty) throw Exception('English is required');
      if (!['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].contains(level)) {
        throw Exception('Invalid level');
      }
      if (category.trim().isEmpty) throw Exception('Category is required');

      final svc = ref.read(wordServiceProvider);

      // Clean locales: remove empty entries
      final cleanedLocales = <String, Map<String, String>>{};
      locales.forEach((lang, m) {
        final term = (m['term'] ?? '').trim();
        final meaning = (m['meaning'] ?? '').trim();
        if (term.isEmpty && meaning.isEmpty) return;
        cleanedLocales[lang] = {
          if (term.isNotEmpty) 'term': term,
          if (meaning.isNotEmpty) 'meaning': meaning,
        };
      });

      final id = editId ?? slugify(enTerm);

      final Map<String, dynamic> body = {
        'category': category.trim(),
        'level': level.trim(),
        'locales': cleanedLocales,
      };

      final exists = await svc.exists(id);

      if (editId != null) {
        if (!exists) throw Exception('Document not found: $id');
        await svc.update(id, body);
      } else {
        if (exists && !overwrite) {
          throw Exception('This word already exists ($id)');
        }
        if (exists) {
          await svc.update(id, body);
        } else {
          await svc.create(id, body);
        }
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
