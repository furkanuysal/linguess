// lib/features/admin/admin_words_list_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/admin/presentation/providers/is_admin_provider.dart';
import 'package:linguess/features/admin/presentation/providers/word_list_provider.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete word?'),
        content: Text('This will permanently delete: $id'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(wordServiceProvider).delete(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deleted: $id')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdminAsync = ref.watch(isAdminProvider);
    final filter = ref.watch(wordsFilterProvider);
    final words = ref.watch(wordsListProvider);

    // taxonomy
    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);

    return isAdminAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (isAdmin) {
        if (!isAdmin) {
          return const Scaffold(
            body: Center(child: Text('Only admins can access this page.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Words'),
            actions: [
              IconButton(
                tooltip: 'Add word',
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
                            'Cat err: $e',
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
                              hint: const Text('Category'),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('All'),
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
                            'Lvl err: $e',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        data: (lvls) {
                          final items = lvls.map((l) => l.id).toList();
                          return SizedBox(
                            width: 140,
                            child: DropdownButtonFormField<String>(
                              value: filter.level.isEmpty ? null : filter.level,
                              hint: const Text('Level'),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('All'),
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
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search English…',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),
                      IconButton(
                        tooltip: 'Clear',
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
                        ? const Center(child: Text('No words'))
                        : ListView.separated(
                            itemCount: words.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
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
                                      tooltip: 'Edit',
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        context.push(
                                          '/admin/words/add',
                                          extra: {'editId': id},
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
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
      },
    );
  }
}
