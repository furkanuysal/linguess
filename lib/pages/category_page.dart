import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/pages/word_game_page.dart';
import 'package:linguess/providers/word_game_provider.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/generated/app_localizations_extensions.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
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
                  title: Text(
                    AppLocalizations.of(context)!.categoryTitle(category.id),
                  ),
                  subtitle: Text(
                    '${AppLocalizations.of(context)!.wordCount}: ${category.wordCount ?? 0}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordGamePage(
                          selectedValue: category.id,
                          mode: 'category',
                        ),
                      ),
                    ).then((_) {
                      // Geri dönüldüğünde bu blok çalışır.
                      // 'ref.invalidate' kullanarak provider'ı sıfırlıyoruz.
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
