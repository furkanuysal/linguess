import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/core/theme/rarity_colors.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_buttons.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_icon.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

void showItemDetailsDialog(
  BuildContext context,
  WidgetRef ref, {
  required ShopItem item,
  required bool isOwned,
  required bool isEquipped,
  required bool isLocked,
  VoidCallback? onBuy,
  VoidCallback? onEquip,
  VoidCallback? onUnequip,
}) {
  final scheme = Theme.of(context).colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final appLang =
      ref.read(settingsControllerProvider).value?.appLangCode ??
      Localizations.localeOf(context).languageCode;

  bool localEquipped = isEquipped;

  final screenWidth = MediaQuery.of(context).size.width;

  // Mobile: %85 - Tablet/Web: max 460 px
  final double dialogWidth = screenWidth < 600 ? screenWidth * 0.85 : 460;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) {
      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onVerticalDragEnd: (_) => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                alignment: Alignment.center,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: Colors.black26),
                  ),
                  AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    width: dialogWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: RarityColors.colorOf(
                          item.rarity,
                          scheme.outlineVariant,
                        ),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RarityColors.colorOf(
                            item.rarity,
                            scheme.outlineVariant,
                          ).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: 'shop_item_${item.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: ShopItemIcon(
                                item: item,
                                scheme: scheme,
                                size: 64,
                                borderRadius: 16,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              item.nameFor(appLang),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.descFor(appLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isLocked)
                              Text(
                                '${l10n.level}: ${item.requiredLevel}',
                                style: TextStyle(color: scheme.error),
                              )
                            else
                              ShopItemButtons.buildBottomSection(
                                context,
                                scheme,
                                l10n,
                                isOwned: isOwned,
                                isEquipped: localEquipped,
                                price: item.price,
                                onBuy: onBuy,
                                onEquip: onEquip,
                                onUnequip: onUnequip,
                                localSetState: () =>
                                    setState(() => localEquipped = true),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
