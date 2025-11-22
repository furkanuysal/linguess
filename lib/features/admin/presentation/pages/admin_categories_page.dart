import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/admin/presentation/providers/admin_categories_provider.dart';
import 'package:linguess/features/admin/presentation/providers/supported_langs_provider.dart';
import 'package:linguess/core/presentation/widgets/gradient_card.dart';
import 'package:linguess/features/game/data/models/category_model.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/repositories/category_repository.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(adminCategoriesProvider);
    final repo = ref.watch(categoryRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.manageCategories,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        actions: [
          IconButton(
            tooltip: l10n.addCategory,
            icon: Icon(Icons.add, color: scheme.primary),
            onPressed: () => _openAddDialog(context, ref, repo),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return Center(child: Text(l10n.noDataToShow));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final c = items[i];

                    final leadingIcon = c.icon != null
                        ? Icon(
                            IconData(
                              int.parse(c.icon!),
                              fontFamily: 'MaterialIcons',
                            ),
                          )
                        : const Icon(Icons.category);

                    return GradientCard(
                      onTap: () => _openEditDialog(context, ref, repo, c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onTap: null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          leading: leadingIcon,
                          title: Text(
                            c.id,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('index: ${c.index}'),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                tooltip: l10n.moveUpText,
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: i == 0
                                    ? null
                                    : () async {
                                        final prev = items[i - 1];
                                        await repo.swapIndices(
                                          idA: c.id,
                                          indexA: c.index,
                                          idB: prev.id,
                                          indexB: prev.index,
                                        );
                                      },
                              ),
                              IconButton(
                                tooltip: l10n.moveDownText,
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: i == items.length - 1
                                    ? null
                                    : () async {
                                        final next = items[i + 1];
                                        await repo.swapIndices(
                                          idA: c.id,
                                          indexA: c.index,
                                          idB: next.id,
                                          indexB: next.index,
                                        );
                                      },
                              ),
                              IconButton(
                                tooltip: l10n.updateCategoryText,
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _openEditDialog(context, ref, repo, c),
                              ),
                              IconButton(
                                tooltip: l10n.deleteCategoryText,
                                icon: const Icon(Icons.delete_forever),
                                onPressed: () =>
                                    _confirmDelete(context, repo, c.id),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // ADD
  Future<void> _openAddDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryRepository repo,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final idCtrl = TextEditingController();
    final iconCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final langs = List<String>.from(ref.read(supportedLangsProvider))..sort();
    final labels = ref.read(languageLabelsProvider);
    final transCtrls = _initTransCtrls(langs);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.addCategory),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _IdField(controller: idCtrl, label: l10n.categoryIdFormLabel),
                  const SizedBox(height: 10),
                  _IconField(
                    controller: iconCtrl,
                    label: l10n.categoryIconFormLabel,
                  ),
                  const SizedBox(height: 16),
                  _TranslationsSection(
                    langs: langs,
                    labels: labels,
                    ctrls: transCtrls,
                    title: l10n.translationsText,
                    subtitle: l10n.categoryAddSubtitle,
                    l10n: l10n,
                    enRequired: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final translations = _collectTranslations(langs, transCtrls);
              final next = await repo.nextIndex();

              final model = CategoryModel(
                id: idCtrl.text.trim(),
                index: next,
                icon: _trimOrNull(iconCtrl.text),
                translations: translations,
              );

              await repo.addCategory(model);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.addCategory),
          ),
        ],
      ),
    );

    idCtrl.dispose();
    iconCtrl.dispose();
    _disposeCtrls(transCtrls);
  }

  // EDIT
  Future<void> _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryRepository repo,
    CategoryModel c,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final iconCtrl = TextEditingController(text: c.icon ?? '');
    final formKey = GlobalKey<FormState>();

    final langs = List<String>.from(ref.read(supportedLangsProvider))..sort();
    final labels = ref.read(languageLabelsProvider);
    final transCtrls = _initTransCtrls(langs, initial: c.translations);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${l10n.updateCategoryText}: ${c.id}'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _IconField(
                    controller: iconCtrl,
                    label: l10n.categoryIconFormLabel,
                  ),
                  const SizedBox(height: 16),
                  _TranslationsSection(
                    langs: langs,
                    labels: labels,
                    ctrls: transCtrls,
                    title: l10n.translationsText,
                    subtitle: l10n.categoryEditSubtitle,
                    l10n: l10n,
                    enRequired: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              // merge: empty fields are preserved
              final merged = Map<String, String>.from(c.translations)
                ..addAll(
                  _collectTranslations(langs, transCtrls, keepEmpty: false),
                );

              final updated = CategoryModel(
                id: c.id,
                index: c.index,
                icon: _trimOrNull(iconCtrl.text),
                translations: merged,
              );

              await repo.updateCategory(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.saveText),
          ),
        ],
      ),
    );

    iconCtrl.dispose();
    _disposeCtrls(transCtrls);
  }

  // DELETE
  Future<void> _confirmDelete(
    BuildContext context,
    CategoryRepository repo,
    String id,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteCategoryText),
        content: Text(l10n.deleteCategoryConfirmation(id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteCategoryText),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteCategory(id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.categorySuccessfullyDeleted}: $id')),
      );
    }
  }
}

// Helpers (logic)
Map<String, TextEditingController> _initTransCtrls(
  List<String> langs, {
  Map<String, String>? initial,
}) {
  return {
    for (final l in langs) l: TextEditingController(text: initial?[l] ?? ''),
  };
}

void _disposeCtrls(Map<String, TextEditingController> ctrls) {
  for (final c in ctrls.values) {
    c.dispose();
  }
}

Map<String, String> _collectTranslations(
  List<String> langs,
  Map<String, TextEditingController> ctrls, {
  bool keepEmpty = false, // false → throw away empty entries
}) {
  final out = <String, String>{};
  for (final l in langs) {
    final v = ctrls[l]!.text.trim();
    if (v.isNotEmpty || keepEmpty) out[l] = v;
  }
  return out;
}

String? _trimOrNull(String? s) {
  final t = (s ?? '').trim();
  return t.isEmpty ? null : t;
}

//  UI Helpers
class _IdField extends StatelessWidget {
  const _IdField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.tag),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty)
          ? AppLocalizations.of(context)!.requiredText
          : null,
    );
  }
}

class _IconField extends StatelessWidget {
  const _IconField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.apps),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TranslationsSection extends StatelessWidget {
  const _TranslationsSection({
    required this.langs,
    required this.labels,
    required this.ctrls,
    required this.title,
    required this.subtitle,
    required this.l10n,
    this.enRequired = true,
  });

  final List<String> langs;
  final Map<String, String> labels;
  final Map<String, TextEditingController> ctrls;
  final String title;
  final String subtitle;
  final AppLocalizations l10n;
  final bool enRequired;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, title, subtitle: subtitle),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.dividerColor.withValues(alpha: 0.4)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // EN first
              TextFormField(
                controller: ctrls['en']!,
                decoration: _langDecoration(
                  context,
                  labels['en'] ?? 'English',
                  required: enRequired,
                ),
                validator: enRequired
                    ? (v) => (v == null || v.trim().isEmpty)
                          ? l10n.requiredText
                          : null
                    : null,
              ),
              const SizedBox(height: 10),
              // Others
              for (final lang in langs.where((l) => l != 'en')) ...[
                TextFormField(
                  controller: ctrls[lang]!,
                  decoration: _langDecoration(
                    context,
                    labels[lang] ?? lang.toUpperCase(),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Widget _sectionHeader(BuildContext context, String title, {String? subtitle}) {
  final t = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 6),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: t.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.translate, size: 18, color: t.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

InputDecoration _langDecoration(
  BuildContext context,
  String label, {
  bool required = false,
}) {
  final t = Theme.of(context);
  return InputDecoration(
    labelText: required ? '$label *' : label,
    prefixIcon: const Icon(Icons.language),
    filled: true,
    fillColor: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: t.dividerColor.withValues(alpha: 0.5)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
