import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/features/game/word_game_state.dart';
import 'package:linguess/providers/category_repository_provider.dart';
import 'package:linguess/providers/learned_count_provider.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (categories) {
          // Invalidate relevant progress providers when categories are loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final category in categories) {
              ref.invalidate(
                progressProvider(
                  ProgressParams(mode: 'category', id: category.id),
                ),
              );
            }
          });

          if (categories.isEmpty) {
            return Center(child: Text(l10n.noDataToShow));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
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
                        ref.invalidate(
                          progressProvider(
                            ProgressParams(mode: 'category', id: category.id),
                          ),
                        );
                      });
                },
              );
            },
          );
        },
      ),
    );
  }
}
