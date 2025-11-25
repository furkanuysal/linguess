import 'package:flutter/material.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/presentation/controllers/achievement_toast_controller.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AchievementToastWidget extends ConsumerWidget {
  const AchievementToastWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievement = ref.watch(achievementToastProvider);
    final l10n = AppLocalizations.of(context);
    final shopItemsAsync = ref.watch(shopItemsProvider);

    if (achievement == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n!.achievementUnlockedText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (achievement.reward != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              achievement.reward is GoldReward
                                  ? Icons.monetization_on
                                  : Icons.inventory_2,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Builder(
                              builder: (context) {
                                if (achievement.reward is GoldReward) {
                                  return Text(
                                    '+${(achievement.reward as GoldReward).amount} ${l10n.gold}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  );
                                } else if (achievement.reward is ItemReward) {
                                  final itemId =
                                      (achievement.reward as ItemReward).itemId;
                                  final itemName = shopItemsAsync.maybeWhen(
                                    data: (items) {
                                      final item = items.firstWhere(
                                        (i) => i.id == itemId,
                                        orElse: () => ShopItem(
                                          id: itemId,
                                          type: ShopItemType.other,
                                          price: 0,
                                          requiredLevel: 0,
                                          rarity: 'common',
                                          iconUrl: '',
                                          translations: {},
                                        ),
                                      );
                                      return item.nameFor(l10n.localeName);
                                    },
                                    orElse: () => 'New Item!',
                                  );

                                  return Text(
                                    itemName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(achievementToastProvider.notifier).hideToast(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
