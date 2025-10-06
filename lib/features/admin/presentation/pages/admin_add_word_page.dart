import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/admin_custom_styles.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/locale_utils.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final labels = ref.watch(languageLabelsProvider);
    final saving = ref.watch(addWordControllerProvider).isLoading;

    final appLangCode = ref
        .watch(settingsControllerProvider)
        .value!
        .appLangCode;

    final categoriesAsync = ref.watch(categoriesProvider);
    final levelsAsync = ref.watch(levelsProvider);
    final wordAsync = widget.editId == null
        ? const AsyncValue.data(null)
        : ref.watch(wordByIdProvider(widget.editId!));

    final isEdit = widget.editId != null;

    final langsOrdered = ['en', ..._langs.where((l) => l != 'en')];
    final screenW = MediaQuery.of(context).size.width;
    final isTwoCol = screenW >= 900; // 2 column for wide screens
    const gap = 12.0;
    final usable = screenW - 32; // list padding total
    final cardW = isTwoCol ? (usable - gap) / 2 : usable;

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
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar(
        title: l10n.addUpdateWordTitle,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        actions: [
          IconButton(
            tooltip: l10n.close,
            icon: Icon(Icons.close, color: scheme.primary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.overwriteIfExists,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch.adaptive(
                      value: isEdit ? true : _overwrite,
                      onChanged: isEdit
                          ? null
                          : (v) => setState(() => _overwrite = v),
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.saveText),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Category
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                    data: (categories) {
                      return dropdownContainer(
                        context: context,
                        label: l10n.category,
                        icon: Icons.category_outlined,
                        child: appDropdownFormField<String>(
                          context: context,
                          value: _selectedCategory,
                          hint: l10n.selectCategory,
                          items: [
                            for (final c in categories)
                              DropdownMenuItem(
                                value: c.id,
                                child: Text(c.titleFor(appLangCode)),
                              ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v),
                          validator: (v) =>
                              v == null ? l10n.requiredText : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Level
                  levelsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('${l10n.errorOccurred}: $e'),
                    data: (levels) {
                      return dropdownContainer(
                        context: context,
                        label: l10n.level,
                        icon: Icons.school_outlined,
                        child: appDropdownFormField<String>(
                          context: context,
                          value: _selectedLevel,
                          hint: l10n.selectLevel,
                          items: [
                            for (final l in levels)
                              DropdownMenuItem(
                                value: l.id,
                                child: Text(l.id.toUpperCase()),
                              ),
                          ],
                          onChanged: (v) => setState(() => _selectedLevel = v),
                          validator: (v) =>
                              v == null ? l10n.requiredText : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Language fields
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final lang in langsOrdered)
                        SizedBox(
                          width: isTwoCol ? cardW : double.infinity,
                          child: LangCard(
                            langCode: lang,
                            langLabel: labels[lang] ?? lang.toUpperCase(),
                            required: lang == 'en',
                            initiallyExpanded: true,
                            child: LangFields(
                              lang: lang,
                              langLabel: labels[lang] ?? lang.toUpperCase(),
                              termCtrl: _termCtrls[lang]!,
                              meaningCtrl: _meaningCtrls[lang]!,
                              exampleSentenceCtrl: _exampleSentenceCtrls[lang]!,
                              requiredField: lang == 'en',
                              readOnly: isEdit && lang == 'en',
                              requiredText: l10n.requiredText,
                            ),
                          ),
                        ),
                    ],
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
