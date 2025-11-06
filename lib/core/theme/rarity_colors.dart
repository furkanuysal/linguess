import 'package:flutter/material.dart';

// Rarity colors mapping
class RarityColors {
  static const Map<String, Color> rarityMap = {
    'common': Color(0xFFA0A0A0),
    'uncommon': Color(0xFF1CAC78),
    'rare': Color(0xFF3B59FF),
    'epic': Color(0xFFA335EE),
    'legendary': Color(0xFFFF8000),
    'mythic': Color(0xFFFF2222),
  };

  // Get color by rarity with fallback
  static Color colorOf(String? rarity, Color fallback) {
    if (rarity == null) return fallback;
    return rarityMap[rarity.toLowerCase()] ?? fallback;
  }
}
