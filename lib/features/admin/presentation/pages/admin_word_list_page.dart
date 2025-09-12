// lib/features/admin/admin_words_list_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/admin/presentation/providers/word_list_provider.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdminWordsListPage extends ConsumerStatefulWidget {
  const AdminWordsListPage({super.key});

  @override
  ConsumerState<AdminWordsListPage> createState() => _AdminWordsListPageState();
}

class _AdminWordsListPageState extends ConsumerState<AdminWordsListPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final f = ref.read(wordsFilterProvider);
      ref.read(wordsFilterProvider.notifier).state = f.copyWith(search: v);
    });
  }

  Future<void> _confirmDelete(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteWordText),
        content: Text(l10n.deleteWordBody(id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteWordText),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(wordServiceProvider).delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.wordSuccessfullyDeleted}: $id')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(wordsFilterProvider);
    final words = ref.watch(wordsListProvider);

    // taxonomy
    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wordsListText),
        actions: [
          IconButton(
            tooltip: l10n.addWordTitle,
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/words/add'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // FILTER BAR
              Row(
                children: [
                  // Category dropdown
                  categoriesAsync.when(
                    loading: () => const SizedBox(
                      width: 160,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                    error: (e, _) => SizedBox(
                      width: 160,
                      child: Text(
                        '${l10n.errorOccurred}: $e',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    data: (cats) {
                      final items = cats.map((c) => c.id).toList();
                      return SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          value: filter.category.isEmpty
                              ? null
                              : filter.category,
                          hint: Text(l10n.category),
                          items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text(l10n.allText),
                            ),
                            for (final n in items)
                              DropdownMenuItem(value: n, child: Text(n)),
                          ],
                          onChanged: (v) {
                            final f = ref.read(wordsFilterProvider);
                            ref.read(wordsFilterProvider.notifier).state = f
                                .copyWith(category: v ?? '');
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Level dropdown
                  levelsAsync.when(
                    loading: () => const SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                    error: (e, _) => SizedBox(
                      width: 120,
                      child: Text(
                        '${l10n.errorOccurred}: $e',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    data: (lvls) {
                      final items = lvls.map((l) => l.id).toList();
                      return SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<String>(
                          value: filter.level.isEmpty ? null : filter.level,
                          hint: Text(l10n.level),
                          items: [
                            DropdownMenuItem(
                              value: '',
                              child: Text(l10n.allText),
                            ),
                            for (final n in items)
                              DropdownMenuItem(value: n, child: Text(n)),
                          ],
                          onChanged: (v) {
                            final f = ref.read(wordsFilterProvider);
                            ref.read(wordsFilterProvider.notifier).state = f
                                .copyWith(level: v ?? '');
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Search
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l10n.searchTheWordEnglish,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: l10n.clearText,
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(wordsFilterProvider.notifier).state =
                          const WordsFilter();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // LIST
              Expanded(
                child: words.isEmpty
                    ? Center(child: Text(l10n.noWordsFound))
                    : ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final w = words[i];
                          final id = w['__id'] as String;
                          final category = (w['category'] ?? '').toString();
                          final level = (w['level'] ?? '').toString();
                          final en = (w['translations']?['en'] ?? '')
                              .toString();
                          final tr = (w['translations']?['tr'] ?? '')
                              .toString();

                          return ListTile(
                            title: Text(en),
                            subtitle: Text(
                              '$category • $level${tr.isNotEmpty ? ' • tr: $tr' : ''}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: l10n.updateWordText,
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    context.push(
                                      '/admin/words/add',
                                      extra: {'editId': id},
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: l10n.deleteWordText,
                                  icon: const Icon(Icons.delete_forever),
                                  onPressed: () => _confirmDelete(id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
