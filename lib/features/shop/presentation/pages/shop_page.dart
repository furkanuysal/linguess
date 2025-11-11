import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/core/utils/auth_utils.dart';
import 'package:linguess/features/auth/presentation/providers/user_equipped_provider.dart';
import 'package:linguess/features/shop/data/providers/inventory_provider.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_header.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card/shop_item_card.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final user = currentUser();

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(inventoryProvider);
        ref.invalidate(avatarImageProvider);
        ref.invalidate(avatarFrameProvider);
      });
    }

    final itemsAsync = ref.watch(shopItemsProvider);
    final invAsync = ref.watch(inventoryProvider);
    final statsAsync = ref.watch(userStatsShopProvider);

    final tabs = [
      (icon: Icons.category, label: l10n.category, type: 'category'),
      (icon: Icons.person, label: l10n.avatarsLabel, type: 'avatar'),
      (icon: Icons.filter_frames, label: l10n.framesLabel, type: 'frame'),
      (icon: Icons.landscape, label: l10n.backgroundsLabel, type: 'background'),
      (icon: Icons.star, label: l10n.otherItemsLabel, type: 'other'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: l10n.shopTitle,
          leading: IconButton(
            onPressed: () => context.canPop() ? context.pop() : null,
            icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: scheme.primary,
            labelColor: scheme.primary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final tab in tabs)
                Tab(icon: Icon(tab.icon, size: 20), text: tab.label),
            ],
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const GradientBackground(),
            SafeArea(
              child: Column(
                children: [
                  // Header (gold + level info)
                  statsAsync.when(
                    data: (stats) => ShopHeader(
                      gold: stats['gold'] ?? 0,
                      level: stats['level'] ?? 1,
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      children: [
                        for (final tab in tabs)
                          _buildShopGrid(
                            context,
                            ref,
                            type: tab.type,
                            itemsAsync: itemsAsync,
                            invAsync: invAsync,
                            statsAsync: statsAsync,
                            l10n: l10n,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopGrid(
    BuildContext context,
    WidgetRef ref, {
    required String type,
    required AsyncValue<List<dynamic>> itemsAsync,
    required AsyncValue<List<dynamic>> invAsync,
    required AsyncValue<Map<String, dynamic>> statsAsync,
    required AppLocalizations l10n,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final user = currentUser();

    return itemsAsync.when(
      data: (items) {
        final filtered = items.where((e) => e.type == type).toList();

        return invAsync.when(
          data: (inv) => statsAsync.maybeWhen(
            data: (stats) {
              final userLevel = stats['level'] ?? 1;

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noItemsAvailable,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final isOwned =
                      user != null && inv.any((e) => e['id'] == item.id);
                  final isEquipped =
                      user != null &&
                      inv.any(
                        (e) => e['id'] == item.id && e['equipped'] == true,
                      );

                  return ShopItemCard(
                    item: item,
                    isLocked: userLevel < item.requiredLevel,
                    isOwned: isOwned,
                    isEquipped: isEquipped,
                    onBuy: () async {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.signInToBuyItems),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      final repo = ref.read(inventoryRepositoryProvider);
                      try {
                        await repo.buyItem(item.id);
                        ref.invalidate(inventoryProvider);
                        ref.invalidate(userStatsShopProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.purchaseSuccessful),
                              backgroundColor: Colors.green[600],
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red[600],
                          ),
                        );
                      }
                    },
                    onEquip: () async {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.signInToEquipItems),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      final repo = ref.read(inventoryRepositoryProvider);
                      await repo.equipItem(item.id, item.type);
                      ref.invalidate(inventoryProvider);
                      ref.invalidate(avatarImageProvider);
                      ref.invalidate(avatarFrameProvider);
                    },
                  );
                },
              );
            },
            orElse: () => const Center(child: CircularProgressIndicator()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
    );
  }
}
