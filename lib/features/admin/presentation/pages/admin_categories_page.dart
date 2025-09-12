// lib/features/admin/presentation/pages/admin_categories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/admin/presentation/providers/admin_categories_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageCategories),
        actions: [
          IconButton(
            tooltip: l10n.addCategory,
            icon: const Icon(Icons.add),
            onPressed: () => _openAddDialog(context, repo),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        data: (items) {
          if (items.isEmpty) return Center(child: Text(l10n.noDataToShow));
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = items[i];
              return ListTile(
                leading: c.icon != null
                    ? Icon(
                        IconData(
                          int.parse(c.icon!),
                          fontFamily: 'MaterialIcons',
                        ),
                      )
                    : const Icon(Icons.category),
                title: Text(c.id),
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
                      onPressed: () => _openEditDialog(context, repo, c),
                    ),
                    IconButton(
                      tooltip: l10n.deleteCategoryText,
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () => _confirmDelete(context, repo, c.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddDialog(
    BuildContext context,
    CategoryRepository repo,
  ) async {
    final idCtrl = TextEditingController();
    final iconCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.addCategory),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: idCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.categoryIdFormLabel,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.requiredText
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: iconCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.categoryIconFormLabel,
                  ),
                ),
              ],
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
              final next = await repo.nextIndex();
              final model = CategoryModel(
                id: idCtrl.text.trim(),
                index: next,
                icon: iconCtrl.text.trim().isEmpty
                    ? null
                    : iconCtrl.text.trim(),
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
  }

  Future<void> _openEditDialog(
    BuildContext context,
    CategoryRepository repo,
    CategoryModel c,
  ) async {
    final iconCtrl = TextEditingController(text: c.icon ?? '');
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${l10n.updateCategoryText}: ${c.id}'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 360,
            child: TextFormField(
              controller: iconCtrl,
              decoration: InputDecoration(
                labelText: l10n.categoryIconFormLabel,
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
              final updated = CategoryModel(
                id: c.id, // id immutable
                index: c.index, // index protected
                icon: iconCtrl.text.trim().isEmpty
                    ? null
                    : iconCtrl.text.trim(),
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
  }

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
        content: Text('${l10n.deleteCategoryConfirmation}: $id'),
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
