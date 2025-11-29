import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/achievements/data/models/achievement_model.dart';
import 'package:linguess/features/shop/data/models/shop_item_model.dart';
import 'package:linguess/features/shop/data/models/shop_item_type.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.def,
    required this.earned,
    required this.progressAsync,
    required this.shopItemsAsync,
  });

  final AchievementModel def;
  final bool earned;
  final AsyncValue<dynamic> progressAsync; // null or AchievementProgress
  final AsyncValue<List<dynamic>> shopItemsAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Card style
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.surface, scheme.surfaceContainerHigh],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: earned
                ? Border.all(
                    color: scheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.emoji_events,
            color: earned ? scheme.primary : scheme.onSurface,
            size: 26,
          ),
        ),
        title: Text(
          def.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubtitle(theme, l10n),
            if (def.reward != null) ...[
              const SizedBox(height: 8),
              _buildReward(context, theme, l10n),
            ],
          ],
        ),
        trailing: earned
            ? const Icon(Icons.check_circle, color: Colors.green)
            : Icon(
                Icons.check_circle_outline,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
      ),
    );
  }

  Widget _buildReward(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final reward = def.reward!;
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                reward is GoldReward
                    ? Icons.monetization_on
                    : Icons.inventory_2,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              if (reward is GoldReward)
                Text(
                  '${reward.amount} ${l10n.gold}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (reward is ItemReward)
                Builder(
                  builder: (context) {
                    final itemId = reward.itemId;
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
                      orElse: () => l10n.loadingText,
                    );

                    return Text(
                      itemName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
            ],
          ),
          if (earned)
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: scheme.primary.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, AppLocalizations l10n) {
    final scheme = theme.colorScheme;

    // Default: just description
    Widget subtitle = Text(def.description);

    // Loading
    if (!earned && progressAsync is AsyncLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.description),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: null,
              minHeight: 8,
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      );
    }

    // Error
    if (!earned && progressAsync is AsyncError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.description),
          const SizedBox(height: 6),
          Text(
            l10n.errorLoadingProgress,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      );
    }

    // Value
    if (!earned && progressAsync.hasValue) {
      final value = progressAsync.value; // null or AchievementProgress
      if (value != null) {
        final current = value.current as int;
        final target = value.target as int;
        final percent = value.percent as int;
        final ratio = (value.ratio as double).clamp(0, 1);

        subtitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(def.description),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio as double,
                minHeight: 8,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('$current / $target', style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  '$percent%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }

    return subtitle;
  }
}
