class WordModel {
  final String id;
  final String category;
  final String level;
  final Map<String, String> translations;

  WordModel({
    required this.id,
    required this.category,
    required this.level,
    required this.translations,
  });

  factory WordModel.fromJson(String id, Map<String, dynamic> json) {
    return WordModel(
      id: id,
      category: json['category'] as String,
      level: json['level'] as String,
      translations: Map<String, String>.from(json['translations']),
    );
  }

  // For writing to Firestore
  Map<String, dynamic> toCreateJson() {
    return {'category': category, 'level': level, 'translations': translations};
  }

  Map<String, dynamic> toUpdateJson() {
    return {'category': category, 'level': level, 'translations': translations};
  }
}
