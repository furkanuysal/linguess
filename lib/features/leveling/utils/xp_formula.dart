import 'dart:math';

// XP Calculation Formula
// Level 1: 100 XP
// Level 15: ≈ 17,000 XP (total)
// Curve: 100 * (level ^ 1.13)
int requiredXp(int level) => (100 * pow(level, 1.13)).round();
