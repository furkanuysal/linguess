import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linguess/core/theme/custom_styles.dart';
import 'package:linguess/core/theme/gradient_background.dart';
import 'package:linguess/features/shop/data/providers/shop_provider.dart';
import 'package:linguess/features/shop/presentation/widgets/shop_item_card.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync = ref.watch(shopItemsProvider);

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
            child: itemsAsync.when(
              data: (items) => GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final item = items[i];
                  final userLevel = 2; // TODO: Fetch actual user level
                  final ownedIds = [
                    'silver_frame',
                  ]; // TODO: Fetch actual owned item IDs

                  return ShopItemCard(
                    item: item,
                    isLocked: userLevel < item.requiredLevel,
                    isOwned: ownedIds.contains(item.id),
                    onBuy: () {},
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.errorOccurred}: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
