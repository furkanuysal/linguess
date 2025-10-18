import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/game/presentation/widgets/category_list_tile.dart';
import 'package:linguess/features/game/presentation/widgets/gradient_choice_chip.dart';
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
  String? selectedMode;

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

                  // Category list
                  Expanded(
                    flex: 4,
                    child: categoriesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('${l10n.errorOccurred}: $e')),
                      data: (categories) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return CategoryListTile(
                              id: category.id,
                              title: category.titleFor(appLang),
                              iconCodePoint: category.icon,
                              isSelected: category.id == selectedCategoryId,
                              onTap: () => setState(() {
                                selectedCategoryId = category.id;
                              }),
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
                          return GradientChoiceChip(
                            label: lvl.id,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => selectedLevelId = lvl.id);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Mode selection (term / meaning)
                  Text(
                    l10n.selectPlayMode,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      GradientChoiceChip(
                        label: l10n.wordText,
                        isSelected: selectedMode == 'term',
                        onTap: () => setState(() => selectedMode = 'term'),
                      ),
                      GradientChoiceChip(
                        label: l10n.meaningText,
                        isSelected: selectedMode == 'meaning',
                        onTap: () => setState(() => selectedMode = 'meaning'),
                      ),
                    ],
                  ),

                  // Selected filters display + clear button
                  if (selectedCategoryId != null ||
                      selectedLevelId != null ||
                      selectedMode != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
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
                                // Sliding selected filters text
                                Expanded(
                                  child: SizedBox(
                                    height:
                                        22, // fixed height to prevent overflow
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final categoryText = categoriesAsync.when(
                                                data: (categories) {
                                                  final selectedCategory =
                                                      categories
                                                          .where(
                                                            (cat) =>
                                                                cat.id ==
                                                                selectedCategoryId,
                                                          )
                                                          .firstOrNull;
                                                  final selectedCategoryName =
                                                      selectedCategory
                                                          ?.titleFor(appLang) ??
                                                      l10n.categoryNotSelected;
                                                  return selectedCategoryName;
                                                },
                                                loading: () => '...',
                                                error: (_, _) => '',
                                              );
                                              return Text(
                                                categoryText,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: scheme
                                                          .onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('•'),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedLevelId ??
                                                l10n.levelNotSelected,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('•'),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedMode == null
                                                ? l10n.modeNotSelected
                                                : selectedMode == 'term'
                                                ? l10n.wordText
                                                : l10n.meaningText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Clear selection button
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
                                      selectedMode = null;
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

                  // Start button
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
                        (selectedCategoryId != null &&
                            selectedLevelId != null &&
                            selectedMode != null)
                        ? () {
                            final query =
                                '?category=${selectedCategoryId!}&level=${selectedLevelId!}';
                            final modeSegment = selectedMode == 'meaning'
                                ? 'meaning'
                                : 'general';
                            context.push('/game/combined/$modeSegment$query');
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
