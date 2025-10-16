import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/game/presentation/providers/word_game_provider.dart';
import 'package:linguess/features/game/presentation/widgets/category_card.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

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
    final appLang = ref.watch(settingsControllerProvider).value!.appLangCode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: l10n.appTitle,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: GradientBackground()),
          SafeArea(
            child: categoriesAsync.when(
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
                  // Use ListView + physics to allow pull-to-refresh even when empty
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(categoriesProvider);
                      await ref.read(categoriesProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(l10n.noDataToShow),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(categoriesProvider);
                    await ref.read(categoriesProvider.future);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.15,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final title = category.titleFor(appLang);
                      return CategoryCard(
                        id: category.id,
                        title: title,
                        iconCodePoint:
                            category.icon, // Material icon code point
                        onTap: () async {
                          await context.push('/game/category/${category.id}');
                          ref.invalidate(
                            progressProvider(
                              ProgressParams(mode: 'category', id: category.id),
                            ),
                          );
                          ref.invalidate(
                            wordGameProvider(
                              WordGameParams(
                                modes: {GameModeType.category},
                                filters: {'category': category.id},
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
