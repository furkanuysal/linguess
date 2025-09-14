// lib/providers/words_list_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linguess/features/admin/data/services/word_service.dart';

final wordServiceProvider = Provider((ref) => WordAdminService());

class WordsFilter {
  final String category;
  final String level;
  final String search; // Search box in the UI (case-insensitive)
  const WordsFilter({this.category = '', this.level = '', this.search = ''});

  WordsFilter copyWith({String? category, String? level, String? search}) =>
      WordsFilter(
        category: category ?? this.category,
        level: level ?? this.level,
        search: search ?? this.search,
      );
}

class WordsFilterNotifier extends Notifier<WordsFilter> {
  @override
  WordsFilter build() => const WordsFilter();

  void setCategory(String? category) =>
      state = state.copyWith(category: category ?? '');

  void setLevel(String? level) => state = state.copyWith(level: level ?? '');

  void setSearch(String? search) =>
      state = state.copyWith(search: (search ?? '').trim());

  void reset() => state = const WordsFilter();
}

// State to be controlled from the UI
final wordsFilterProvider = NotifierProvider<WordsFilterNotifier, WordsFilter>(
  WordsFilterNotifier.new,
);

// List from Firestore according to the filter
final wordsQueryProvider =
    StreamProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>((ref) {
      final filter = ref.watch(wordsFilterProvider);
      final svc = ref.watch(wordServiceProvider);
      final q = svc.query(
        category: filter.category.isEmpty ? null : filter.category,
        level: filter.level.isEmpty ? null : filter.level,
      );
      return q.snapshots().map((snap) => snap.docs);
    });

// Final list after applying search (client-side contains)
final wordsListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final filter = ref.watch(wordsFilterProvider);
  final docsAsync = ref.watch(wordsQueryProvider);
  return docsAsync.maybeWhen(
    data: (docs) {
      final s = filter.search.trim().toLowerCase();
      final list = docs.map((d) {
        final data = d.data();
        data['__id'] = d.id; // Add doc id for easy access
        return data;
      }).toList();

      if (s.isEmpty) return list;

      return list.where((w) {
        final en = ((w['translations']?['en']) ?? '').toString().toLowerCase();
        return en.contains(s);
      }).toList();
    },
    orElse: () => const [],
  );
});
