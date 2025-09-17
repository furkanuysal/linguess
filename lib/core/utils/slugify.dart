library;

String slugify(String s) {
  return s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\\s]'), ' ')
      .replaceAll(RegExp(r'\\s+'), ' ')
      .trim();
}
