class CategoryModel {
  final String id;
  final int index;
  final String? icon;
  final Map<String, String> translations;

  CategoryModel({
    required this.id,
    required this.index,
    this.icon,
    required this.translations,
  });

  factory CategoryModel.fromJson(String id, Map<String, dynamic> json) {
    final rawIndex = json['index'];
    final indexValue = rawIndex is int
        ? rawIndex
        : rawIndex is double
        ? rawIndex.toInt()
        : 0;
    final trans =
        (json['translations'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ??
        const <String, String>{};

    return CategoryModel(
      id: id,
      index: indexValue,
      icon: json['icon'] as String?,
      translations: trans,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      if (icon != null) 'icon': icon,
      'translations': translations,
    };
  }

  // Returns the title for the given locale, with fallbacks.
  String titleFor(String locale, {String fallbackLang = 'en'}) {
    final lower = locale.toLowerCase();
    final short = lower.split('_').first.split('-').first;
    return translations[lower] ??
        translations[short] ??
        translations[fallbackLang] ??
        id;
  }
}
