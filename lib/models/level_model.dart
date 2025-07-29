class LevelModel {
  final String id;
  final int index;
  final int? wordCount;

  LevelModel({required this.id, required this.index, this.wordCount});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'],
      index: (json['index'] is int)
          ? json['index'] as int
          : (json['index'] is double)
          ? (json['index'] as double).toInt()
          : 0, // ya da default değer ver
      wordCount: json['wordCount'] != null
          ? (json['wordCount'] is int)
                ? json['wordCount'] as int
                : (json['wordCount'] is double)
                ? (json['wordCount'] as double).toInt()
                : 0 // ya da default değer ver
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      if (wordCount != null) 'wordCount': wordCount,
    };
  }
}
