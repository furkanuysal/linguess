class CategoryModel {
  final String id;
  final int index;
  final String? icon;

  CategoryModel({required this.id, required this.index, this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      index: (json['index'] is int)
          ? json['index'] as int
          : (json['index'] is double)
          ? (json['index'] as double).toInt()
          : 0, // or default value
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'index': index, if (icon != null) 'icon': icon};
  }
}
