import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/locale_utils.dart';
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
      ref.read(wordsFilterProvider.notifier).setSearch(v);
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
    final scheme = Theme.of(context).colorScheme;
    final filter = ref.watch(wordsFilterProvider);
    final words = ref.watch(wordsListProvider);

    // taxonomy
    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.wordsListText,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        actions: [
          IconButton(
            tooltip: l10n.addWordTitle,
            icon: Icon(Icons.add, color: scheme.primary),
            onPressed: () => context.push('/admin/words/add'),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
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
                                ref
                                    .read(wordsFilterProvider.notifier)
                                    .setCategory(v ?? '');
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
                                ref
                                    .read(wordsFilterProvider.notifier)
                                    .setLevel(v ?? '');
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
                          ref.read(wordsFilterProvider.notifier).reset();
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
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final w = Map<String, dynamic>.from(words[i]);
                              final id = w['__id'] as String;
                              final category = (w['category'] ?? '').toString();
                              final level = (w['level'] ?? '').toString();

                              // Read from locales safely
                              final en = w.termOf('en');
                              final tr = w.termOf('tr');

                              return ListTile(
                                title: Text(en.isNotEmpty ? en : '—'),
                                subtitle: Text(
                                  '$category • $level'
                                  '${tr.isNotEmpty ? ' • tr: $tr' : ''}',
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
        ],
      ),
    );
  }
}
