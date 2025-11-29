import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/presentation/widgets/gradient_choice_chip.dart';
import 'package:linguess/features/profile/presentation/widgets/learned_words_widgets.dart';

class LearnedWordsPage extends ConsumerStatefulWidget {
  const LearnedWordsPage({super.key});

  @override
  ConsumerState<LearnedWordsPage> createState() => _LearnedWordsPageState();
}

class _LearnedWordsPageState extends ConsumerState<LearnedWordsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final settings = ref.watch(settingsControllerProvider).value;
    final targetLangCode = settings?.targetLangCode ?? 'en';
    final appLangCode = settings?.appLangCode ?? 'en';

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.learnedWordsText,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Search Bar with Glassmorphism
                Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: scheme.onSurface),
                            decoration: InputDecoration(
                              hintText: l10n.searchWordLabel,
                              hintStyle: TextStyle(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: scheme.primary,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        FocusScope.of(context).unfocus();
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: scheme.surface.withValues(alpha: 0.6),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0),

                // Filter Chips
                SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GradientChoiceChip(
                              label: l10n.allText,
                              isSelected: _selectedCategoryId == null,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = null;
                                });
                              },
                            ),
                          ),
                          ...categoriesAsync.maybeWhen(
                            data: (cats) => cats.map((c) {
                              final title = c.titleFor(appLangCode);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GradientChoiceChip(
                                  label: title,
                                  isSelected: _selectedCategoryId == c.id,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = c.id;
                                    });
                                  },
                                ),
                              );
                            }),
                            orElse: () => [],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),

                // List Content
                Expanded(
                  child: ref
                      .watch(learnedWordsDetailsProvider)
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            '${l10n.errorOccurred}: $e',
                            style: TextStyle(color: scheme.error),
                          ),
                        ),
                        data: (items) {
                          final filteredItems = items.where((item) {
                            final w = item.word;
                            final matchesCategory =
                                _selectedCategoryId == null ||
                                w.category == _selectedCategoryId;
                            final appText = w.termOf(appLangCode);
                            final matchesSearch = appText
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase());
                            return matchesCategory && matchesSearch;
                          }).toList();

                          // Summary Header
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '${l10n.totalLearnedWordsText}: ${filteredItems.length}',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ).animate().fadeIn(delay: 200.ms),

                              Expanded(
                                child: filteredItems.isEmpty
                                    ? _buildEmptyState(context, l10n, scheme)
                                    : ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          8,
                                          16,
                                          24,
                                        ),
                                        itemCount: filteredItems.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, i) {
                                          final item = filteredItems[i];
                                          final w = item.word;
                                          final targetText = w.termOf(
                                            targetLangCode,
                                          );
                                          final appText = w.termOf(appLangCode);
                                          final titleText = _cap(targetText);
                                          final subtitleText = appText;
                                          final cat = ref.watch(
                                            categoryByIdProvider(w.category),
                                          );
                                          final categoryTitle =
                                              cat?.titleFor(appLangCode) ??
                                              w.category;

                                          return GradientListItem(
                                                iconCodePoint: cat?.icon,
                                                title: titleText,
                                                subtitle: subtitleText,
                                                level: w.level,
                                                learnedAt: item.learnedAt,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        WordDetailsDialog(
                                                          iconCodePoint:
                                                              cat?.icon,
                                                          title: titleText,
                                                          targetLangCode:
                                                              targetLangCode,
                                                          appLangCode:
                                                              appLangCode,
                                                          targetText:
                                                              targetText,
                                                          appText: appText,
                                                          level: w.level,
                                                          category:
                                                              categoryTitle,
                                                          learnedAt:
                                                              item.learnedAt,
                                                        ),
                                                  );
                                                },
                                              )
                                              .animate(
                                                delay: (50 * i)
                                                    .ms, // Stagger effect
                                              )
                                              .fadeIn(duration: 400.ms)
                                              .slideY(begin: 0.2, end: 0);
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme scheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? l10n.noWordsFound
                : l10n.learnedWordsEmpty,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(),
    );
  }
}
