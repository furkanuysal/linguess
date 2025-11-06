import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/theme/rarity_colors.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopItemCard extends ConsumerWidget {
  const ShopItemCard({
    super.key,
    required this.item,
    this.onBuy,
    this.onEquip,
    this.isOwned = false,
    this.isEquipped = false,
    this.isLocked = false,
  });

  final ShopItem item;
  final VoidCallback? onBuy;
  final VoidCallback? onEquip;
  final bool isOwned;
  final bool isEquipped;
  final bool isLocked;

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

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main content
          Container(
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
                  color: rarityColor.withValues(
                    alpha: 0.35,
                  ), // Glow effect based on rarity
                  blurRadius: 4,
                  spreadRadius: 1.5,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 4),

                // Item icon
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
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

                const SizedBox(height: 10),

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

                const SizedBox(height: 6),

                // Bottom section: Buy / Equip / Equipped button
                _buildBottomSection(context, scheme, l10n),
              ],
            ),
          ),

          // Lock + blur overlay
          if (isLocked)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 42,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.level}: ${item.requiredLevel}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    if (isLocked) return const SizedBox.shrink();

    final isHighRarity = item.rarity == 'legendary' || item.rarity == 'mythic';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: isOwned
          ? (isEquipped
                // Equipped button
                ? ElevatedButton.icon(
                    key: const ValueKey('equipped'),
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary.withValues(alpha: 0.4),
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text(
                      l10n.equippedLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                // Equip button
                : ElevatedButton.icon(
                    key: const ValueKey('equip'),
                    onPressed: onEquip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_fill, size: 18),
                    label: Text(
                      l10n.equipLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ))
          : // Buy button
            Container(
              key: const ValueKey('buy'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isHighRarity
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFFFD54F),
                          Color(0xFFFFB300),
                          Color(0xFFFF8F00),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isHighRarity ? null : Colors.amber.shade600,
                boxShadow: [
                  if (isHighRarity)
                    BoxShadow(
                      color: Colors.orangeAccent.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black.withValues(alpha: 0.9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onBuy,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 22,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.price}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
