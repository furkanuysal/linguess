import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/admin/presentation/providers/add_word_controller_provider.dart';
import 'package:linguess/features/admin/presentation/controllers/add_word_controller.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/admin/presentation/providers/is_admin_provider.dart';
import 'package:linguess/features/admin/presentation/providers/word_by_id_provider.dart';

class AdminAddWordPage extends ConsumerStatefulWidget {
  const AdminAddWordPage({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<AdminAddWordPage> createState() => _AdminAddWordPageState();
}

class _AdminAddWordPageState extends ConsumerState<AdminAddWordPage> {
  final _formKey = GlobalKey<FormState>();
  final _en = TextEditingController();
  final _tr = TextEditingController();
  final _de = TextEditingController();
  final _es = TextEditingController();

  String? _selectedCategory;
  String? _selectedLevel;
  bool _overwrite = false;
  bool _prefilled = false; // To fill the form once with doc data in edit mode

  @override
  void dispose() {
    _en.dispose();
    _tr.dispose();
    _de.dispose();
    _es.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final category = _selectedCategory;
    final level = _selectedLevel;
    if (category == null || level == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chooseCategoryAndLevel)));
      return;
    }

    final translations = <String, String>{
      'en': _en.text,
      if (_tr.text.trim().isNotEmpty) 'tr': _tr.text.trim(),
      if (_de.text.trim().isNotEmpty) 'de': _de.text.trim(),
      if (_es.text.trim().isNotEmpty) 'es': _es.text.trim(),
    };

    try {
      await ref
          .read(addWordControllerProvider.notifier)
          .addOrUpdate(
            category: category,
            level: level,
            translations: translations,
            overwrite: _overwrite,
            editId: widget.editId, // Update the same doc in edit mode
          );

      if (!mounted) return;

      final savedId = widget.editId ?? slugify(_en.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.savedSuccessfully} ✅  (id: $savedId)')),
      );

      // Only clear the form in add mode
      if (widget.editId == null) {
        _en.clear();
        _tr.clear();
        _de.clear();
        _es.clear();
        setState(() => _overwrite = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.errorOccurred}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isAdminAsync = ref.watch(isAdminProvider);
    final saving = ref.watch(addWordControllerProvider).isLoading;

    // Dropdown data
    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);

    // If in edit mode, fetch the document
    final wordAsync = widget.editId == null
        ? const AsyncValue.data(null)
        : ref.watch(wordByIdProvider(widget.editId!));

    // If edit data is available, fill the form once
    wordAsync.whenData((w) {
      if (w != null && !_prefilled) {
        _en.text = (w.translations['en'] ?? '');
        _tr.text = (w.translations['tr'] ?? '');
        _de.text = (w.translations['de'] ?? '');
        _es.text = (w.translations['es'] ?? '');
        _selectedCategory = w.category;
        _selectedLevel = w.level;
        _overwrite = true; // Always enabled in edit mode
        _prefilled = true;
        setState(() {});
      }
    });

    final isEdit = widget.editId != null;

    return isAdminAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('${l10n.errorOccurred}: $e'))),
      data: (isAdmin) {
        if (!isAdmin) {
          return Scaffold(
            body: Center(child: Text(l10n.errorOnlyAdminsCanAccess)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.addUpdateWordTitle),
            actions: [
              IconButton(
                tooltip: l10n.close,
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ——— CATEGORY ———
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                    data: (categories) {
                      final names = categories.map((c) => c.id).toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        hint: Text(l10n.selectCategory),
                        items: [
                          for (final n in names)
                            DropdownMenuItem(value: n, child: Text(n)),
                        ],
                        onChanged: (v) => setState(() => _selectedCategory = v),
                        decoration: InputDecoration(labelText: l10n.category),
                        validator: (v) => v == null ? l10n.requiredText : null,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ——— LEVEL ———
                  levelsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                    data: (levels) {
                      final codes = levels.map((l) => l.id).toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        hint: Text(l10n.selectLevel),
                        items: [
                          for (final code in codes)
                            DropdownMenuItem(value: code, child: Text(code)),
                        ],
                        onChanged: (v) => setState(() => _selectedLevel = v),
                        decoration: InputDecoration(labelText: l10n.level),
                        validator: (v) => v == null ? l10n.requiredText : null,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ——— TRANSLATIONS ———
                  TextFormField(
                    controller: _en,
                    decoration: InputDecoration(
                      labelText: 'English (en)*',
                      fillColor: isEdit ? Colors.grey.shade200 : null,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.requiredText
                        : null,
                    readOnly: isEdit, // Cannot be changed in edit mode
                    style: isEdit
                        ? TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tr,
                    decoration: const InputDecoration(
                      labelText: 'Turkish (tr)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _de,
                    decoration: const InputDecoration(labelText: 'German (de)'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _es,
                    decoration: const InputDecoration(
                      labelText: 'Spanish (es)',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ——— OVERWRITE ———
                  SwitchListTile(
                    value: isEdit
                        ? true
                        : _overwrite, // Always true in edit mode
                    onChanged: isEdit
                        ? null
                        : (v) => setState(() => _overwrite = v),
                    title: Text(l10n.overwriteIfExists),
                  ),
                  const SizedBox(height: 12),

                  // ——— SAVE ———
                  ElevatedButton.icon(
                    onPressed: saving ? null : _save,
                    icon: saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(l10n.saveText),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
