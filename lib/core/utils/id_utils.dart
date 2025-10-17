// Core-wide ID helpers (docId, slugs, sanitization)

// Produces a Firestore-safe docId string.
// Only [A–Z a–z 0–9 _ . -] remain; others are replaced with '_'.
import 'package:linguess/features/game/presentation/controllers/word_game_state.dart';

String sanitizeForDocId(String input) {
  return input.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
}

// New system: supports multiple filters and modes.
// Examples:
// - {modes: [daily]} → "daily"
// - {filters: {'category': 'food'}} → "category:food"
// - {filters: {'category': 'food', 'level': 'A2'}} → "category:food|level:A2"
String makeResumeDocIdFromFilters({
  required Set<GameModeType> modes,
  required Map<String, String> filters,
}) {
  // Daily mode is used alone
  if (modes.length == 1 && modes.contains(GameModeType.daily)) {
    return 'daily:general';
  }

  final updatedFilters = Map<String, String>.from(filters);
  if (modes.contains(GameModeType.meaning) &&
      !updatedFilters.containsKey('meaning')) {
    updatedFilters['meaning'] = 'general';
  }

  // If there are no filters, use a safe fallback
  if (updatedFilters.isEmpty) {
    return 'general';
  }

  // Sort filters alphabetically and sanitize
  final entries = updatedFilters.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final parts = entries.map((e) {
    final key = sanitizeForDocId(e.key.toLowerCase());
    final value = sanitizeForDocId(e.value);
    return '$key:$value';
  }).toList();

  return parts.join('|'); // example: "category:food|level:A2"
}
