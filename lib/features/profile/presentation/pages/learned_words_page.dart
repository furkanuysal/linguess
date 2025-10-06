import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/game/data/models/word_model.dart';
import 'package:linguess/features/game/data/providers/word_repository_provider.dart';
import 'package:linguess/features/game/data/repositories/word_repository.dart';
import 'package:linguess/core/theme/gradient_background.dart';

class LearnedWordsPage extends ConsumerWidget {
  const LearnedWordsPage({super.key});

  Future<List<WordModel>> _loadDetails(
    List<String> ids,
    WordRepository repo,
    String sortLang,
  ) async {
    if (ids.isEmpty) return const [];
    final list = await Future.wait(ids.map(repo.fetchWordById));
    final words = list.whereType<WordModel>().toList();
    words.sort((a, b) {
      final ta = (a.termOf(sortLang)).toLowerCase();
      final tb = (b.termOf(sortLang)).toLowerCase();
      return ta.compareTo(tb);
    });
    return words;
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final settings = ref.watch(settingsControllerProvider).value;
    final targetLangCode = settings?.targetLangCode ?? 'en';
    final appLangCode = settings?.appLangCode ?? 'en';

    final idsAsync = ref.watch(learnedWordIdsProvider);
    final repo = ref.watch(wordRepositoryProvider);

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
            child: idsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
              data: (ids) {
                if (ids.isEmpty) {
                  return Center(child: Text(l10n.noDataToShow));
                }
                return FutureBuilder<List<WordModel>>(
                  future: _loadDetails(ids, repo, targetLangCode),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text('${l10n.errorOccurred}: ${snap.error}'),
                      );
                    }
                    final words = snap.data ?? const [];
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: words.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final w = words[i];
                        final targetText = w.termOf(targetLangCode);
                        final appText = w.termOf(appLangCode);
                        final titleText = _cap(targetText);
                        final subtitleText = appText;
                        final cat = ref.watch(categoryByIdProvider(w.category));
                        final categoryTitle =
                            cat?.titleFor(appLangCode) ?? w.category;
                        return _GradientListItem(
                          leadingIcon: Icons.menu_book_outlined,
                          title: titleText,
                          subtitle: subtitleText,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => _WordDetailsDialog(
                                title: titleText,
                                targetLangCode: targetLangCode,
                                appLangCode: appLangCode,
                                targetText: targetText,
                                appText: appText,
                                level: w.level,
                                category: categoryTitle,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient list item
class _GradientListItem extends StatelessWidget {
  const _GradientListItem({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(leadingIcon, color: scheme.onSurface, size: 26),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

/// Dialog showing word details
class _WordDetailsDialog extends StatelessWidget {
  const _WordDetailsDialog({
    required this.title,
    required this.targetLangCode,
    required this.appLangCode,
    required this.targetText,
    required this.appText,
    required this.level,
    required this.category,
  });

  final String title;
  final String targetLangCode;
  final String appLangCode;
  final String targetText;
  final String appText;
  final String level;
  final String category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            '${AppLocalizations.of(context)!.translation} (${targetLangCode.toUpperCase()})',
            targetText,
            context,
          ),
          _buildInfoRow(
            '${AppLocalizations.of(context)!.translation} (${appLangCode.toUpperCase()})',
            appText,
            context,
          ),
          _buildInfoRow(AppLocalizations.of(context)!.level, level, context),
          _buildInfoRow(
            AppLocalizations.of(context)!.category,
            category,
            context,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
      backgroundColor: scheme.surface,
    );
  }

  Widget _buildInfoRow(String key, String value, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: ',
            style: baseStyle?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: baseStyle?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
