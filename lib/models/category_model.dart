class CategoryModel {
  final String id;
  final int index;
  final String? icon;
  final int? wordCount;

  CategoryModel({
    required this.id,
    required this.index,
    this.icon,
    this.wordCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      index: (json['index'] is int)
          ? json['index'] as int
          : (json['index'] is double)
          ? (json['index'] as double).toInt()
          : 0, // ya da default değer ver
      icon: json['icon'] as String?,
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
      if (icon != null) 'icon': icon,
      if (wordCount != null) 'wordCount': wordCount,
    };
  }
}
