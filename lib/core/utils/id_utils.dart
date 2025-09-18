// Core-wide ID helpers (docId, slugs, sanitization)

// Produces a Firestore-safe docId string.
// Only [A–Z a–z 0–9 _ . -] remain; others are replaced with '_'.
String sanitizeForDocId(String input) {
  return input.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
}

// Composite docId for a Linguess resume document.
// Example: category:food, level:A2, daily:20250915
String makeResumeDocId({
  required String mode, // "category" | "level" | "daily" | ...
  required String selectedValue, // "food" | "A2" | "20250915" ...
}) {
  final safe = sanitizeForDocId(selectedValue);
  return '$mode:$safe';
}
