import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/providers/learned_count_provider.dart';
import 'package:linguess/providers/word_game_provider.dart';
import 'package:linguess/models/category_model.dart';
import 'package:linguess/repositories/category_repository.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _categories = await _categoryRepository.fetchCategories();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  leading: category.icon != null
                      ? Image.asset(category.icon!)
                      : null,
                  title: Text(l10n.categoryTitle(category.id)),
                  subtitle: ref
                      .watch(
                        progressProvider(
                          ProgressParams(mode: 'category', id: category.id),
                        ),
                      )
                      .when(
                        data: (p) => Text(
                          p.hasUser
                              ? '${p.learnedCount}/${p.totalCount} ${l10n.learnedCountText}'
                              : '${p.totalCount} ${l10n.totalWordText}',
                        ),
                        loading: () => const Text('...'),
                        error: (_, _) => const Text('-'),
                      ),
                  onTap: () {
                    context
                        .push(
                          '/game/category/${category.id}',
                          extra: WordGameParams(
                            mode: 'category',
                            selectedValue: category.id,
                          ),
                        )
                        .then((_) {
                          // Revalidate the provider when returning
                          ref.invalidate(
                            wordGameProvider(
                              WordGameParams(
                                mode: 'category',
                                selectedValue: category.id,
                              ),
                            ),
                          );
                        });
                  },
                );
              },
            ),
    );
  }
}
