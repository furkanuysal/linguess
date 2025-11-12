// Item types for the shop items in the application.
enum ShopItemType {
  avatar,
  frame,
  background,
  category,
  font,
  xpBoost,
  goldBoost,
  other;

  // Converts a string from Firestore to the corresponding enum value.
  static ShopItemType fromString(String type) {
    switch (type) {
      case 'avatar':
        return ShopItemType.avatar;
      case 'frame':
        return ShopItemType.frame;
      case 'background':
        return ShopItemType.background;
      case 'category':
        return ShopItemType.category;
      case 'font':
        return ShopItemType.font;
      case 'xp_boost':
        return ShopItemType.xpBoost;
      case 'gold_boost':
        return ShopItemType.goldBoost;
      default:
        return ShopItemType.other;
    }
  }

  // Converts the enum back to a string for writing to Firestore
  String get nameString {
    switch (this) {
      case ShopItemType.avatar:
        return 'avatar';
      case ShopItemType.frame:
        return 'frame';
      case ShopItemType.background:
        return 'background';
      case ShopItemType.category:
        return 'category';
      case ShopItemType.font:
        return 'font';
      case ShopItemType.xpBoost:
        return 'xp_boost';
      case ShopItemType.goldBoost:
        return 'gold_boost';
      case ShopItemType.other:
        return 'other';
    }
  }
}
