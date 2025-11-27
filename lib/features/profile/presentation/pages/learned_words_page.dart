import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/game/presentation/widgets/gradient_choice_chip.dart';

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

                                          return _GradientListItem(
                                                iconCodePoint: cat?.icon,
                                                title: titleText,
                                                subtitle: subtitleText,
                                                level: w.level,
                                                learnedAt: item.learnedAt,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        _WordDetailsDialog(
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

/// Gradient list item
class _GradientListItem extends StatelessWidget {
  const _GradientListItem({
    this.iconCodePoint,
    required this.title,
    required this.subtitle,
    required this.level,
    this.learnedAt,
    this.onTap,
  });

  final String? iconCodePoint;
  final String title;
  final String subtitle;
  final String level;
  final DateTime? learnedAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr = learnedAt != null
        ? DateFormat.yMMMd(
            Localizations.localeOf(context).languageCode,
          ).format(learnedAt!)
        : null;

    IconData iconData = Icons.menu_book_rounded;
    if (iconCodePoint != null) {
      try {
        iconData = IconData(
          int.parse(iconCodePoint!),
          fontFamily: 'MaterialIcons',
        );
      } catch (_) {}
    }

    return Material(
      elevation: 2,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.surface, scheme.surfaceContainerHigh],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(iconData, color: scheme.onSurface, size: 28),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: scheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (dateStr != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog showing word details
class _WordDetailsDialog extends StatelessWidget {
  const _WordDetailsDialog({
    this.iconCodePoint,
    required this.title,
    required this.targetLangCode,
    required this.appLangCode,
    required this.targetText,
    required this.appText,
    required this.level,
    required this.category,
    this.learnedAt,
  });

  final String? iconCodePoint;
  final String title;
  final String targetLangCode;
  final String appLangCode;
  final String targetText;
  final String appText;
  final String level;
  final String category;
  final DateTime? learnedAt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr = learnedAt != null
        ? DateFormat.yMMMd(
            Localizations.localeOf(context).languageCode,
          ).format(learnedAt!)
        : null;

    IconData iconData = Icons.menu_book_rounded;
    if (iconCodePoint != null) {
      try {
        iconData = IconData(
          int.parse(iconCodePoint!),
          fontFamily: 'MaterialIcons',
        );
      } catch (_) {}
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Text(
                    targetText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildChip(
                        context,
                        label: level.toUpperCase(),
                        icon: Icons.star_outline,
                        color: scheme.surfaceContainerHigh,
                        onColor: scheme.onSurfaceVariant,
                        isBold: true,
                      ),
                      _buildChip(
                        context,
                        label: category,
                        icon: Icons.category_outlined,
                        color: scheme.surfaceContainerHigh,
                        onColor: scheme.onSurfaceVariant,
                      ),
                      if (dateStr != null)
                        _buildChip(
                          context,
                          label: dateStr,
                          icon: Icons.calendar_today_outlined,
                          color: scheme.surfaceContainerHigh,
                          onColor: scheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required Color color,
    required Color onColor,
    IconData? icon,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: onColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: onColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
