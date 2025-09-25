class WordModel {
  final String id;
  final String category;
  final String level;
  final Map<String, Map<String, String>> locales;

  WordModel({
    required this.id,
    required this.category,
    required this.level,
    Map<String, Map<String, String>>? locales,
  }) : locales = locales ?? const {};

  factory WordModel.fromJson(String id, Map<String, dynamic> json) {
    final rawLoc = json['locales'];
    final Map<String, Map<String, String>> locales = {};

    if (rawLoc is Map) {
      rawLoc.forEach((langKey, val) {
        final inner = <String, String>{};
        if (val is Map) {
          final term = val['term'];
          final meaning = val['meaning'];
          final exampleSentence = val['exampleSentence'];

          if (term is String && term.trim().isNotEmpty) {
            inner['term'] = term.trim();
          }
          if (meaning is String && meaning.trim().isNotEmpty) {
            inner['meaning'] = meaning.trim();
          }
          if (exampleSentence is String && exampleSentence.trim().isNotEmpty) {
            inner['exampleSentence'] = exampleSentence.trim();
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
      locales: locales,
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'level': level, 'locales': locales};
  }
}
