class LevelModel {
  final String id;
  final int index;

  LevelModel({required this.id, required this.index});

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'],
      index: (json['index'] is int)
          ? json['index'] as int
          : (json['index'] is double)
          ? (json['index'] as double).toInt()
          : 0, // ya da default değer ver
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'index': index};
  }
}
