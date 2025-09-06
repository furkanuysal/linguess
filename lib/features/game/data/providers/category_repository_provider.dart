import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/data/models/category_model.dart';
import 'package:linguess/features/game/data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.fetchCategories();
});
