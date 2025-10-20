import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/data/providers/availability_provider.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/game/data/providers/sufficiency_provider.dart';
import 'package:linguess/features/game/presentation/widgets/category_card.dart';
import 'package:linguess/features/game/presentation/widgets/category_list_tile.dart';
import 'package:linguess/features/game/presentation/widgets/gradient_choice_chip.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isGridView = false;
  static const _prefKey = 'isGridView_combinedMode';
  bool _isPrefLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey) ?? false;
    setState(() {
      isGridView = saved;
      _isPrefLoaded = true;
    });
  }

  Future<void> _saveViewPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  bool isCombinationEnabled({
    required WidgetRef ref,
    required String? categoryId,
    required String? levelId,
    required String? selectedMode,
  }) {
    final availabilityAsync = ref.watch(
      wordAvailabilityProvider((categoryId, levelId)),
    );
    final sufficiencyAsync = ref.watch(
      wordSufficiencyProvider((categoryId, levelId)),
    );

    final available = availabilityAsync.value ?? true;
    final sufficient = sufficiencyAsync.value ?? true;

    // Time Attack requires 12+, others only need 1+
    return selectedMode == 'timeAttack' ? sufficient : available;
  }

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
        actions: [
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
                  Expanded(
                    flex: 4,
                    child: !_isPrefLoaded
                        ? const Center(child: CircularProgressIndicator())
                        : categoriesAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Center(
                              child: Text('${l10n.errorOccurred}: $e'),
                            ),
                            data: (categories) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                          begin: 0.98,
                                          end: 1.0,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                child: isGridView
                                    ? _buildGrid(categories, appLang)
                                    : _buildList(categories, appLang),
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
                          final enabled = isCombinationEnabled(
                            ref: ref,
                            categoryId: selectedCategoryId,
                            levelId: lvl.id,
                            selectedMode: selectedMode,
                          );
                          return Opacity(
                            opacity: enabled ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !enabled,
                              child: GradientChoiceChip(
                                label: lvl.id,
                                isSelected: isSelected,
                                onTap: () =>
                                    setState(() => selectedLevelId = lvl.id),
                              ),
                            ),
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

                  Builder(
                    builder: (context) {
                      final timeAttackSufficiencyAsync = ref.watch(
                        wordSufficiencyProvider((
                          selectedCategoryId,
                          selectedLevelId,
                        )),
                      );

                      // If no selection is made => active
                      // If a selection is made => active if word is sufficient, otherwise inactive
                      final timeAttackEnabled =
                          (selectedCategoryId == null &&
                              selectedLevelId == null) ||
                          (timeAttackSufficiencyAsync.value ?? false);

                      return Wrap(
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
                            onTap: () =>
                                setState(() => selectedMode = 'meaning'),
                          ),
                          Opacity(
                            opacity: timeAttackEnabled ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !timeAttackEnabled,
                              child: GradientChoiceChip(
                                label: l10n.timeAttackText,
                                isSelected: selectedMode == 'timeAttack',
                                onTap: () =>
                                    setState(() => selectedMode = 'timeAttack'),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            22, // fixed height to prevent overflow
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
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
                                                      return selectedCategory
                                                              ?.titleFor(
                                                                appLang,
                                                              ) ??
                                                          l10n.categoryNotSelected;
                                                    },
                                                    loading: () => '...',
                                                    error: (_, _) => l10n
                                                        .categoryNotSelected,
                                                  );

                                                  final levelText =
                                                      selectedLevelId ??
                                                      l10n.levelNotSelected;

                                                  final modeText =
                                                      selectedMode == null
                                                      ? l10n.modeNotSelected
                                                      : (selectedMode == 'term'
                                                            ? l10n.wordText
                                                            : selectedMode ==
                                                                  'meaning'
                                                            ? l10n.meaningText
                                                            : l10n.timeAttackText);

                                                  final isTA =
                                                      selectedMode ==
                                                      'timeAttack';
                                                  final hasCat =
                                                      selectedCategoryId !=
                                                      null;
                                                  final hasLvl =
                                                      selectedLevelId != null;

                                                  // Helper to add dot separator
                                                  List<Widget> withDot(
                                                    Widget w,
                                                  ) => [
                                                    w,
                                                    const SizedBox(width: 8),
                                                    const Text('•'),
                                                    const SizedBox(width: 8),
                                                  ];

                                                  final textStyle =
                                                      Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: scheme
                                                                .onSurfaceVariant,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          );

                                                  final items = <Widget>[];

                                                  if (isTA &&
                                                      (hasCat ^ hasLvl)) {
                                                    // Only category + TA or only level + TA
                                                    if (hasCat) {
                                                      items.addAll(
                                                        withDot(
                                                          Text(
                                                            categoryText,
                                                            style: textStyle,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      items.addAll(
                                                        withDot(
                                                          Text(
                                                            levelText,
                                                            style: textStyle,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    items.add(
                                                      Text(
                                                        modeText,
                                                        style: textStyle,
                                                      ),
                                                    );
                                                  } else if (isTA &&
                                                      !hasCat &&
                                                      !hasLvl) {
                                                    // Only TA selected → "Category or level not selected • Time Attack"
                                                    items.addAll(
                                                      withDot(
                                                        Text(
                                                          l10n.categoryOrLevelNotSelected,
                                                          style: textStyle,
                                                        ),
                                                      ),
                                                    );
                                                    items.add(
                                                      Text(
                                                        modeText,
                                                        style: textStyle,
                                                      ),
                                                    );
                                                  } else {
                                                    // Other scenarios (including normal modes)
                                                    items.addAll(
                                                      withDot(
                                                        Text(
                                                          categoryText,
                                                          style: textStyle,
                                                        ),
                                                      ),
                                                    );
                                                    items.addAll(
                                                      withDot(
                                                        Text(
                                                          levelText,
                                                          style: textStyle,
                                                        ),
                                                      ),
                                                    );
                                                    items.add(
                                                      Text(
                                                        modeText,
                                                        style: textStyle,
                                                      ),
                                                    );
                                                  }

                                                  return Row(children: items);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (selectedMode == 'timeAttack' &&
                                          ((selectedCategoryId != null &&
                                                  selectedLevelId == null) ||
                                              (selectedCategoryId == null &&
                                                  selectedLevelId != null)))
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            selectedCategoryId != null
                                                ? l10n
                                                      .optionalLevelCanBeSelected // Optional level selection can be made
                                                : l10n.optionalCategoryCanBeSelected, // Optional category selection can be made
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ),
                                    ],
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
                        (selectedMode == 'timeAttack'
                                ? (selectedCategoryId != null ||
                                      selectedLevelId != null)
                                : (selectedCategoryId != null &&
                                      selectedLevelId != null)) &&
                            selectedMode != null
                        ? () {
                            final query =
                                '?category=${selectedCategoryId ?? ''}&level=${selectedLevelId ?? ''}';
                            final modeSegment = switch (selectedMode) {
                              'meaning' => 'meaning',
                              'term' => 'general',
                              'timeAttack' => 'timeAttack',
                              _ => 'general',
                            };
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

  Widget _buildGrid(List categories, String appLang) {
    final refLocal = ref;
    return GridView.builder(
      key: const ValueKey('gridView'),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        final enabled = isCombinationEnabled(
          ref: refLocal,
          categoryId: category.id,
          levelId: selectedLevelId,
          selectedMode: selectedMode,
        );

        return Opacity(
          opacity: enabled ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !enabled,
            child: CategoryCard(
              id: category.id,
              title: category.titleFor(appLang),
              iconCodePoint: category.icon,
              isSelected: isSelected,
              onTap: () => setState(() {
                selectedCategoryId = category.id;
              }),
              showProgress: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List categories, String appLang) {
    final refLocal = ref;
    return ListView.builder(
      key: const ValueKey('listView'),
      padding: const EdgeInsets.only(top: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        final enabled = isCombinationEnabled(
          ref: refLocal,
          categoryId: category.id,
          levelId: selectedLevelId,
          selectedMode: selectedMode,
        );

        return Opacity(
          opacity: enabled ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !enabled,
            child: CategoryListTile(
              id: category.id,
              title: category.titleFor(appLang),
              iconCodePoint: category.icon,
              isSelected: isSelected,
              onTap: () => setState(() {
                selectedCategoryId = category.id;
              }),
            ),
          ),
        );
      },
    );
  }
}
