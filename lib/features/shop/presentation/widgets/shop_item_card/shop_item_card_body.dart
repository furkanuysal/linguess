import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/theme/rarity_colors.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_buttons.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopItemCardBody extends ConsumerWidget {
  const ShopItemCardBody({
    super.key,
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.isLocked,
    this.onBuy,
    this.onEquip,
  });

  final ShopItem item;
  final bool isOwned;
  final bool isEquipped;
  final bool isLocked;
  final VoidCallback? onBuy;
  final VoidCallback? onEquip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final appLang =
        ref.read(settingsControllerProvider).value?.appLangCode ??
        Localizations.localeOf(context).languageCode;
    final rarityColor = RarityColors.colorOf(
      item.rarity,
      scheme.outlineVariant,
    );

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [scheme.surface, scheme.surfaceContainerHigh],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.35),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Hero(
                tag: 'shop_item_${item.id}',
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: rarityColor, width: 1.5),
                      image: DecorationImage(
                        image: NetworkImage(item.iconUrl),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.nameFor(appLang),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLocked ? scheme.outline : scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          if (!isLocked)
            ShopItemButtons.buildBottomSection(
              context,
              scheme,
              l10n,
              isOwned: isOwned,
              isEquipped: isEquipped,
              price: item.price,
              onBuy: onBuy,
              onEquip: onEquip,
            ),
        ],
      ),
    );
  }
}
