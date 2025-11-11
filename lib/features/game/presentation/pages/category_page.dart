import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/presentation/controllers/category_controller.dart';
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/presentation/providers/learned_count_provider.dart';
import 'package:linguess/features/game/presentation/providers/word_game_provider.dart';
import 'package:linguess/features/game/presentation/widgets/category_card.dart';
import 'package:linguess/features/game/presentation/widgets/category_list_tile.dart';
import 'package:linguess/features/game/presentation/widgets/locked_category_widgets/locked_category_card.dart';
import 'package:linguess/features/game/presentation/widgets/locked_category_widgets/locked_category_tile.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  bool isGridView = false;
  static const _prefKey = 'isGridView_categoryPage';
  bool _isPrefLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? true;
    setState(() {
      isGridView = saved;
      _isPrefLoaded = true;
    });
  }

  Future<void> _saveViewPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> _openCategory(String id) async {
    await context.push('/game/category/$id');
    ref.invalidate(progressProvider(ProgressParams(mode: 'category', id: id)));
    ref.invalidate(
      wordGameProvider(
        WordGameParams(
          modes: {GameModeType.category},
          filters: {'category': id},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoriesProvider);
    final appLang = ref.watch(settingsControllerProvider).value!.appLangCode;
    final controller = ref.watch(categoryControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        title: l10n.appTitle,
        actions: [
          if (_isPrefLoaded)
            IconButton(
              tooltip: isGridView ? l10n.listViewTooltip : l10n.gridViewTooltip,
              icon: Icon(
                isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: scheme.primary,
              ),
              onPressed: () {
                setState(() => isGridView = !isGridView);
                _saveViewPreference(isGridView);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GradientBackground()),
          SafeArea(
            child: !_isPrefLoaded
                ? const Center(child: CircularProgressIndicator())
                : categoriesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('${l10n.errorOccurred}: $e')),
                    data: (categories) {
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.97,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: isGridView
                              ? _buildGrid(categories, appLang, controller)
                              : _buildList(categories, appLang, controller),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List categories,
    String appLang,
    CategoryController controller,
  ) {
    return GridView.builder(
      key: const ValueKey('gridView'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final title = category.titleFor(appLang);
        final isBuyable = controller.isBuyable(category.id);
        final isOwned = controller.isOwned(category.id);
        final price = controller.getPrice(category.id);

        if (isBuyable && !isOwned) {
          return LockedCategoryCard(
            title: title,
            price: price,
            iconCodePoint: category.icon,
            onBuy: () async => controller.buyCategory(context, category.id),
          );
        } else {
          return CategoryCard(
            id: category.id,
            title: title,
            iconCodePoint: category.icon,
            onTap: () => _openCategory(category.id),
          );
        }
      },
    );
  }

  Widget _buildList(
    List categories,
    String appLang,
    CategoryController controller,
  ) {
    return ListView.builder(
      key: const ValueKey('listView'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final title = category.titleFor(appLang);
        final isBuyable = controller.isBuyable(category.id);
        final isOwned = controller.isOwned(category.id);
        final price = controller.getPrice(category.id);

        if (isBuyable && !isOwned) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: LockedCategoryTile(
              title: title,
              price: price,
              iconCodePoint: category.icon,
              onBuy: () async => controller.buyCategory(context, category.id),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: CategoryListTile(
              id: category.id,
              title: title,
              iconCodePoint: category.icon,
              isSelected: false,
              onTap: () => _openCategory(category.id),
            ),
          );
        }
      },
    );
  }
}
