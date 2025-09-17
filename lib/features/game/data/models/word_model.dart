class WordModel {
  final String id;
  final String category;
  final String level;
  final Map<String, String> translations;
  final Map<String, Map<String, String>> locales;

  WordModel({
    required this.id,
    required this.category,
    required this.level,
    required this.translations,
    Map<String, Map<String, String>>? locales,
  }) : locales = locales ?? const {};

  factory WordModel.fromJson(String id, Map<String, dynamic> json) {
    // translations safe read
    final rawTr = json['translations'];
    final translations = (rawTr is Map)
        ? rawTr.map<String, String>(
            (k, v) => MapEntry(k.toString(), (v ?? '').toString()),
          )
        : <String, String>{};

    // locales safe read
    final rawLoc = json['locales'];
    final Map<String, Map<String, String>> locales = {};
    if (rawLoc is Map) {
      rawLoc.forEach((langKey, val) {
        final inner = <String, String>{};
        if (val is Map) {
          final term = val['term'];
          final meaning = val['meaning'];
          if (term is String && term.trim().isNotEmpty) inner['term'] = term;
          if (meaning is String && meaning.trim().isNotEmpty) {
            inner['meaning'] = meaning;
          }
        }
        if (inner.isNotEmpty) {
          locales[langKey.toString()] = inner;
        }
      });
    }

    return WordModel(
      id: id,
      category: (json['category'] ?? '') as String,
      level: (json['level'] ?? '') as String,
      translations: translations,
      locales: locales,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'category': category,
      'level': level,
      'translations': translations,
      if (locales.isNotEmpty) 'locales': locales,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'category': category,
      'level': level,
      'translations': translations,
      if (locales.isNotEmpty) 'locales': locales,
    };
  }

  // ---- Helpers ----

  String termOf(String lang) {
    final fromLocales = locales[lang]?['term'];
    if (fromLocales != null && fromLocales.trim().isNotEmpty) {
      return fromLocales;
    }
    return translations[lang] ?? '';
  }

  // Only locales.meaning (no equivalent in translations)
  String? meaningOf(String lang) => locales[lang]?['meaning'];
}
