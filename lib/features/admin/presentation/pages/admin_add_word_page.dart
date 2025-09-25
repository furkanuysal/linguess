import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/features/admin/presentation/providers/add_word_controller_provider.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';
import 'package:linguess/features/game/data/providers/level_repository_provider.dart';
import 'package:linguess/features/admin/presentation/providers/word_by_id_provider.dart';
import 'package:linguess/features/admin/presentation/providers/supported_langs_provider.dart';
import 'package:linguess/features/admin/presentation/widgets/lang_fields.dart';
import 'package:linguess/core/utils/slugify.dart';

class AdminAddWordPage extends ConsumerStatefulWidget {
  const AdminAddWordPage({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<AdminAddWordPage> createState() => _AdminAddWordPageState();
}

class _AdminAddWordPageState extends ConsumerState<AdminAddWordPage> {
  final _formKey = GlobalKey<FormState>();

  late List<String> _langs;
  late Map<String, TextEditingController> _termCtrls;
  late Map<String, TextEditingController> _meaningCtrls;
  late Map<String, TextEditingController> _exampleSentenceCtrls;

  String? _selectedCategory;
  String? _selectedLevel;
  bool _overwrite = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    // get from provider on initial load
    _langs = List.of(ref.read(supportedLangsProvider));
    _termCtrls = {for (final l in _langs) l: TextEditingController()};
    _meaningCtrls = {for (final l in _langs) l: TextEditingController()};
    _exampleSentenceCtrls = {
      for (final l in _langs) l: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in _termCtrls.values) {
      c.dispose();
    }
    for (final c in _meaningCtrls.values) {
      c.dispose();
    }
    for (final c in _exampleSentenceCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureControllersForLangs(Iterable<String> langs) {
    for (final lang in langs) {
      _termCtrls.putIfAbsent(lang, () => TextEditingController());
      _meaningCtrls.putIfAbsent(lang, () => TextEditingController());
      _exampleSentenceCtrls.putIfAbsent(lang, () => TextEditingController());
    }
  }

  Map<String, Map<String, String?>> _buildLocalesPatch() {
    final Map<String, Map<String, String?>> locales = {};
    for (final lang in _langs) {
      final term = _termCtrls[lang]!.text.trim();
      final meaning = _meaningCtrls[lang]!.text.trim();
      final exampleSentence = _exampleSentenceCtrls[lang]!.text.trim();
      if (term.isEmpty && meaning.isEmpty && exampleSentence.isEmpty) continue;
      locales[lang] = {
        if (term.isNotEmpty) 'term': term,
        if (meaning.isNotEmpty) 'meaning': meaning,
        if (exampleSentence.isNotEmpty) 'exampleSentence': exampleSentence,
      };
    }
    return locales;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedLevel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chooseCategoryAndLevel)));
      return;
    }

    try {
      await ref
          .read(addWordControllerProvider.notifier)
          .addOrUpdate(
            category: _selectedCategory!,
            level: _selectedLevel!,
            locales: _buildLocalesPatch(),
            overwrite: _overwrite,
            editId: widget.editId,
          );

      if (!mounted) return;
      final savedId = widget.editId ?? slugify(_termCtrls['en']!.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.savedSuccessfully} ✅ (id: $savedId)')),
      );

      if (widget.editId == null) {
        for (final c in _termCtrls.values) {
          c.clear();
        }
        for (final c in _meaningCtrls.values) {
          c.clear();
        }
        for (final c in _exampleSentenceCtrls.values) {
          c.clear();
        }
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
    final labels = ref.watch(languageLabelsProvider);
    final saving = ref.watch(addWordControllerProvider).isLoading;

    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);
    final wordAsync = widget.editId == null
        ? const AsyncValue.data(null)
        : ref.watch(wordByIdProvider(widget.editId!));

    final isEdit = widget.editId != null;

    // edit prefill: only locales
    wordAsync.whenData((w) {
      if (w != null && !_prefilled) {
        final docLangs = <String>{..._langs, ...w.locales.keys}.toList()
          ..sort();
        _ensureControllersForLangs(docLangs);
        _langs = docLangs;

        for (final lang in _langs) {
          _termCtrls[lang]!.text = (w.locales as Map).termOf(lang);
          _meaningCtrls[lang]!.text = (w.locales as Map).meaningOf(lang)!;
          _exampleSentenceCtrls[lang]!.text = (w.locales as Map)
              .exampleSentenceOf(lang)!;
        }

        _selectedCategory = w.category;
        _selectedLevel = w.level;
        _overwrite = true;
        _prefilled = true;

        if (mounted) setState(() {});
      }
    });

    if (isEdit && !_prefilled && wordAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              // Category
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text(l10n.selectCategory),
                    items: [
                      for (final c in categories)
                        DropdownMenuItem(value: c.id, child: Text(c.id)),
                    ],
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    decoration: InputDecoration(labelText: l10n.category),
                    validator: (v) => v == null ? l10n.requiredText : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Level
              levelsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                data: (levels) {
                  return DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    hint: Text(l10n.selectLevel),
                    items: [
                      for (final l in levels)
                        DropdownMenuItem(value: l.id, child: Text(l.id)),
                    ],
                    onChanged: (v) => setState(() => _selectedLevel = v),
                    decoration: InputDecoration(labelText: l10n.level),
                    validator: (v) => v == null ? l10n.requiredText : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Language fields
              LangFields(
                lang: 'en',
                langLabel: labels['en'] ?? 'English',
                termCtrl: _termCtrls['en']!,
                meaningCtrl: _meaningCtrls['en']!,
                exampleSentenceCtrl: _exampleSentenceCtrls['en']!,
                requiredField: true,
                readOnly: isEdit,
                requiredText: l10n.requiredText,
              ),
              for (final lang in _langs.where((l) => l != 'en'))
                LangFields(
                  lang: lang,
                  langLabel: labels[lang] ?? lang.toUpperCase(),
                  termCtrl: _termCtrls[lang]!,
                  meaningCtrl: _meaningCtrls[lang]!,
                  exampleSentenceCtrl: _exampleSentenceCtrls[lang]!,
                  requiredField: false,
                  readOnly: false,
                  requiredText: l10n.requiredText,
                ),

              const SizedBox(height: 12),

              SwitchListTile(
                value: isEdit ? true : _overwrite,
                onChanged: isEdit
                    ? null
                    : (v) => setState(() => _overwrite = v),
                title: Text(l10n.overwriteIfExists),
              ),
              const SizedBox(height: 12),

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
  }
}
