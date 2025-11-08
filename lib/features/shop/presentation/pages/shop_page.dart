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
import 'package:linguess/features/shop/presentation/widgets/shop_item_card.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final user = currentUser();

    // If user is null, invalidate inventory and avatar providers to reset state
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: l10n.shopTitle,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
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

                // Shop Grid
                Expanded(
                  child: itemsAsync.when(
                    data: (items) => invAsync.when(
                      data: (inv) => statsAsync.maybeWhen(
                        data: (stats) {
                          final userLevel = stats['level'] ?? 1;

                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemBuilder: (_, i) {
                              final item = items[i];

                              // If user is null, no item is considered owned/equipped
                              final isOwned =
                                  user != null &&
                                  inv.any((e) => e['id'] == item.id);
                              final isEquipped =
                                  user != null &&
                                  inv.any(
                                    (e) =>
                                        e['id'] == item.id &&
                                        e['equipped'] == true,
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

                                  final repo = ref.read(
                                    inventoryRepositoryProvider,
                                  );
                                  try {
                                    await repo.buyItem(item.id);
                                    ref.invalidate(inventoryProvider);
                                    ref.invalidate(userStatsShopProvider);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.purchaseSuccessful,
                                          ),
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

                                  final repo = ref.read(
                                    inventoryRepositoryProvider,
                                  );
                                  await repo.equipItem(item.id, item.type);
                                  ref.invalidate(inventoryProvider);
                                  ref.invalidate(avatarImageProvider);
                                  ref.invalidate(avatarFrameProvider);
                                },
                              );
                            },
                          );
                        },
                        orElse: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          Center(child: Text('${l10n.errorOccurred}: $e')),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('${l10n.errorOccurred}: $e')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
