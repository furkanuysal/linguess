import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/game/presentation/widgets/category_card.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class CombinedModeSetupPage extends ConsumerStatefulWidget {
  const CombinedModeSetupPage({super.key});

  @override
  ConsumerState<CombinedModeSetupPage> createState() =>
      _CombinedModeSetupPageState();
}

class _CombinedModeSetupPageState extends ConsumerState<CombinedModeSetupPage> {
  String? selectedCategoryId;
  String? selectedLevelId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final appLang =
        ref.watch(settingsControllerProvider).value?.appLangCode ?? 'en';
    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        title: l10n.customGame,
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GradientBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.selectCategory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category grid
                  Expanded(
                    flex: 4,
                    child: categoriesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('${l10n.errorOccurred}: $e')),
                      data: (categories) {
                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return GestureDetector(
                              onTap: () => setState(() {
                                selectedCategoryId = category.id;
                              }),
                              child: CategoryCard(
                                id: category.id,
                                title: category.titleFor(appLang),
                                iconCodePoint: category.icon,
                                onTap: () => setState(() {
                                  selectedCategoryId = category.id;
                                }),
                                isSelected: category.id == selectedCategoryId,
                                showProgress: true,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    l10n.selectLevel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Level chip list
                  levelsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('${l10n.errorOccurred}: $e')),
                    data: (levels) {
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: levels.map((lvl) {
                          final isSelected = lvl.id == selectedLevelId;
                          return ChoiceChip(
                            label: Text(
                              lvl.id,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                              ),
                            ),
                            checkmarkColor: scheme.onPrimary,
                            selected: isSelected,
                            selectedColor: scheme.primary,
                            backgroundColor: scheme.surfaceContainerHigh
                                .withValues(alpha: 0.8),
                            onSelected: (_) {
                              setState(() => selectedLevelId = lvl.id);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // Selected filters display + clear button
                  if (selectedCategoryId != null || selectedLevelId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.35,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: categoriesAsync.when(
                                    data: (categories) {
                                      final selectedCategory = categories
                                          .where(
                                            (cat) =>
                                                cat.id == selectedCategoryId,
                                          )
                                          .firstOrNull;
                                      final selectedCategoryName =
                                          selectedCategory?.titleFor(appLang);

                                      return Text(
                                        selectedCategoryName ??
                                            l10n.noneSelected,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                    loading: () => Text(
                                      '...',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    error: (_, _) => const SizedBox.shrink(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedLevelId ?? l10n.noneSelected,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                IconButton(
                                  tooltip: l10n.clearSelection,
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedCategoryId = null;
                                      selectedLevelId = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Start game button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 26),
                    label: Text(
                      l10n.startCustomGame,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    onPressed:
                        (selectedCategoryId != null && selectedLevelId != null)
                        ? () {
                            context.push(
                              '/game/combined/general'
                              '?category=${selectedCategoryId!}&level=${selectedLevelId!}',
                            );
                          }
                        : null,
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
