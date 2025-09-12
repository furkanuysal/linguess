import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/data/models/category_model.dart';
import 'package:linguess/features/game/data/providers/category_repository_provider.dart';

final adminCategoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.streamCategories();
});
