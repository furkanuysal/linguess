import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';

class ShopItemCard extends ConsumerWidget {
  const ShopItemCard({
    super.key,
    required this.item,
    this.onBuy,
    this.isOwned = false,
    this.isLocked = false,
  });

  final ShopItem item;
  final VoidCallback? onBuy;
  final bool isOwned;
  final bool isLocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final appLang =
        ref.read(settingsControllerProvider).value?.appLangCode ??
        Localizations.localeOf(context).languageCode;

    final borderColor = switch (item.rarity) {
      'common' => scheme.outlineVariant,
      'rare' => Colors.blueAccent,
      'epic' => Colors.purpleAccent,
      'legendary' => Colors.orangeAccent,
      _ => scheme.outlineVariant,
    };

    // Todo: Do UI improvements
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLocked || isOwned ? null : onBuy,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Item image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(item.iconUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Item name
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

              const SizedBox(height: 4),

              // Price or status
              _buildBottomSection(context, scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, ColorScheme scheme) {
    if (isLocked) {
      return Text(
        'Lv. ${item.requiredLevel}',
        style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600),
      );
    }

    if (isOwned) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: scheme.primary, size: 18),
          const SizedBox(width: 4),
          Text(
            'Owned', // Todo: localization
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // Buyable
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
        const SizedBox(width: 4),
        Text(
          '${item.price}',
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
