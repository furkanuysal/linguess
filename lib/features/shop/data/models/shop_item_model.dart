import 'package:linguess/features/shop/data/models/shop_item_type.dart';

class ShopItem {
  final String id;
  final ShopItemType type;
  final int price;
  final int requiredLevel;
  final String rarity;
  final String iconUrl;
  final Map<String, Map<String, String>> translations;

  ShopItem({
    required this.id,
    required this.type,
    required this.price,
    required this.requiredLevel,
    required this.rarity,
    required this.iconUrl,
    required this.translations,
  });

  factory ShopItem.fromMap(String id, Map<String, dynamic> data) {
    final trans =
        (data['translations'] as Map?)?.map(
          (lang, values) => MapEntry(
            lang.toString(),
            (values as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
          ),
        ) ??
        {};

    return ShopItem(
      id: id,
      type: ShopItemType.fromString(data['type'] ?? 'avatar'),
      price: data['price'] ?? 0,
      requiredLevel: data['requiredLevel'] ?? 0,
      rarity: data['rarity'] ?? 'common',
      iconUrl: data['iconUrl'] ?? '',
      translations: trans,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.nameString,
      'price': price,
      'requiredLevel': requiredLevel,
      'rarity': rarity,
      'iconUrl': iconUrl,
      'translations': translations,
    };
  }

  String nameFor(String locale, {String fallback = 'en'}) {
    final lower = locale.toLowerCase();
    final short = lower.split('_').first.split('-').first;
    return translations[lower]?['name'] ??
        translations[short]?['name'] ??
        translations[fallback]?['name'] ??
        id;
  }

  String descFor(String locale, {String fallback = 'en'}) {
    final lower = locale.toLowerCase();
    final short = lower.split('_').first.split('-').first;
    return translations[lower]?['description'] ??
        translations[short]?['description'] ??
        translations[fallback]?['description'] ??
        '';
  }
}
