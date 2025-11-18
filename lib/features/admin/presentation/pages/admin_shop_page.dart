import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/theme/rarity_colors.dart';
import 'package:linguess/features/admin/presentation/providers/supported_langs_provider.dart';
import 'package:linguess/features/admin/presentation/widgets/gradient_card.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:linguess/features/shop/data/repositories/shop_repository.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_icon.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AdminShopPage extends ConsumerStatefulWidget {
  const AdminShopPage({super.key});

  @override
  ConsumerState<AdminShopPage> createState() => _AdminShopPageState();
}

class _AdminShopPageState extends ConsumerState<AdminShopPage> {
  ShopItemType? _selectedTypeFilter;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = v.toLowerCase().trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final itemsAsync = ref.watch(adminShopListProvider);
    final repo = ref.watch(shopRepositoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.shopTitle,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
        actions: [
          IconButton(
            tooltip: l10n.addShopItemLabel,
            icon: Icon(Icons.add, color: scheme.primary),
            onPressed: () => _openSaveDialog(context, ref, repo, null),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Filter & Search
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Type Filter
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<ShopItemType?>(
                          initialValue: _selectedTypeFilter,
                          decoration: InputDecoration(
                            labelText: l10n.category,
                            isDense: true,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.allText),
                            ),
                            for (final t in ShopItemType.values)
                              DropdownMenuItem(
                                value: t,
                                child: Text(t.nameString.toUpperCase()),
                              ),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedTypeFilter = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search Field
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: l10n.searchShopItemHint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            filled: true,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // List of Items
                Expanded(
                  child: itemsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('${l10n.errorOccurred}: $e')),
                    data: (items) {
                      final filtered = items.where((item) {
                        if (_selectedTypeFilter != null &&
                            item.type != _selectedTypeFilter) {
                          return false;
                        }
                        if (_searchQuery.isNotEmpty) {
                          final matchesId = item.id.toLowerCase().contains(
                            _searchQuery,
                          );
                          final matchesName = item
                              .nameFor('en')
                              .toLowerCase()
                              .contains(_searchQuery);
                          if (!matchesId && !matchesName) return false;
                        }
                        return true;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(child: Text(l10n.noDataToShow));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildListItem(context, ref, repo, item);
                        },
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

  Widget _buildListItem(
    BuildContext context,
    WidgetRef ref,
    ShopRepository repo,
    ShopItem item,
  ) {
    final scheme = Theme.of(context).colorScheme;

    final rarityColor = RarityColors.colorOf(
      item.rarity,
      scheme.onSurfaceVariant,
    );

    return GradientCard(
      onTap: () => _openSaveDialog(context, ref, repo, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: ShopItemIcon(
              item: item,
              scheme: scheme,
              size: 30,
              borderRadius: 10,
            ),
          ),
          title: Text(
            item.nameFor('en'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${item.id}',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _Badge(
                    text: item.type.nameString.toUpperCase(),
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.rarity.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: rarityColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.monetization_on,
                    size: 14,
                    color: Colors.amber[700],
                  ),
                  Text(' ${item.price}'),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _openSaveDialog(context, ref, repo, item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () => _confirmDelete(context, repo, item.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ADD / EDIT DIALOG ---
  Future<void> _openSaveDialog(
    BuildContext context,
    WidgetRef ref,
    ShopRepository repo, // Dynamic yerine Tip güvenli Repo
    ShopItem? existingItem,
  ) async {
    final isEdit = existingItem != null;
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();

    final idCtrl = TextEditingController(text: existingItem?.id ?? '');
    final priceCtrl = TextEditingController(
      text: existingItem?.price.toString() ?? '0',
    );
    final levelCtrl = TextEditingController(
      text: existingItem?.requiredLevel.toString() ?? '0',
    );
    final iconCtrl = TextEditingController(text: existingItem?.iconUrl ?? '');

    ShopItemType selectedType = existingItem?.type ?? ShopItemType.avatar;
    String selectedRarity = existingItem?.rarity ?? 'common';

    final rarities = RarityColors.rarityMap.keys.toList();

    final langs = List<String>.from(ref.read(supportedLangsProvider))..sort();
    final labels = ref.read(languageLabelsProvider);

    final transCtrls =
        <String, ({TextEditingController name, TextEditingController desc})>{};
    for (final lang in langs) {
      final nameVal = existingItem?.translations[lang]?['name'] ?? '';
      final descVal = existingItem?.translations[lang]?['description'] ?? '';
      transCtrls[lang] = (
        name: TextEditingController(text: nameVal),
        desc: TextEditingController(text: descVal),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              isEdit ? l10n.updateShopItemLabel : l10n.addShopItemLabel,
            ),
            content: SizedBox(
              width: 640,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ID & Type
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: idCtrl,
                                enabled: !isEdit,
                                decoration: const InputDecoration(
                                  labelText: 'Item ID (doc_id)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? l10n.requiredText
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<ShopItemType>(
                                initialValue: selectedType,
                                decoration: InputDecoration(
                                  labelText: l10n.typeLabel,
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: ShopItemType.values
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t.nameString),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setStateDialog(() => selectedType = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Price & Level & Rarity
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.priceLabel,
                                  suffixIcon: Icon(
                                    Icons.monetization_on,
                                    size: 16,
                                  ),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? l10n.requiredText : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: levelCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.requiredLevelLabel,
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? l10n.requiredText : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedRarity,
                                decoration: InputDecoration(
                                  labelText: l10n.rarityLabel,
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: rarities.map((r) {
                                  final color = RarityColors.colorOf(
                                    r,
                                    Colors.black,
                                  );
                                  return DropdownMenuItem(
                                    value: r,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(r),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setStateDialog(() => selectedRarity = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Icon Source
                        TextFormField(
                          controller: iconCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.iconSourceLabel,
                            hintText: 'https://..., assets/..., or 0xe5f8',
                            prefixIcon: Icon(Icons.image),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),

                        _ShopTranslationsSection(
                          langs: langs,
                          labels: labels,
                          ctrls: transCtrls,
                          l10n: l10n,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancelText),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final translationsMap = <String, Map<String, String>>{};

                  for (final lang in langs) {
                    final name = transCtrls[lang]!.name.text.trim();
                    final desc = transCtrls[lang]!.desc.text.trim();

                    if (name.isNotEmpty || desc.isNotEmpty) {
                      translationsMap[lang] = {
                        'name': name,
                        'description': desc,
                      };
                    }
                  }

                  final newItem = ShopItem(
                    id: idCtrl.text.trim(),
                    type: selectedType,
                    price: int.tryParse(priceCtrl.text) ?? 0,
                    requiredLevel: int.tryParse(levelCtrl.text) ?? 0,
                    rarity: selectedRarity,
                    iconUrl: iconCtrl.text.trim(),
                    translations: translationsMap,
                  );

                  try {
                    if (isEdit) {
                      await repo.updateItem(newItem);
                    } else {
                      await repo.addItem(newItem);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                    ref.invalidate(shopItemsProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.errorOccurred}: $e')),
                      );
                    }
                  }
                },
                child: Text(l10n.saveText),
              ),
            ],
          );
        },
      ),
    );

    idCtrl.dispose();
    priceCtrl.dispose();
    levelCtrl.dispose();
    iconCtrl.dispose();
    for (final c in transCtrls.values) {
      c.name.dispose();
      c.desc.dispose();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ShopRepository repo,
    String id,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteShopItemLabel),
        content: Text(l10n.deleteShopItemConfirmMessage(id)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelText),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteWordText),
          ),
        ],
      ),
    );

    if (ok == true) {
      await repo.deleteItem(id);
      if (context.mounted) {
        ref.invalidate(shopItemsProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shopItemDeletedMessage(id))),
        );
      }
    }
  }
}

// UI Components
class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ShopTranslationsSection extends StatelessWidget {
  const _ShopTranslationsSection({
    required this.langs,
    required this.labels,
    required this.ctrls,
    required this.l10n,
  });

  final List<String> langs;
  final Map<String, String> labels;
  final Map<String, ({TextEditingController name, TextEditingController desc})>
  ctrls;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.translate, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.translationsText,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        for (final lang in langs) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: t.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.dividerColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[lang] ?? lang.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: t.colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: ctrls[lang]!.name,
                  decoration: InputDecoration(
                    labelText: l10n.nameLabel,
                    isDense: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  validator: (lang == 'en')
                      ? (v) =>
                            (v == null || v.isEmpty) ? l10n.requiredText : null
                      : null,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: ctrls[lang]!.desc,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionLabel,
                    isDense: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
