import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linguess/features/game/data/models/category_model.dart';
import 'package:linguess/features/game/data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.read(categoryRepositoryProvider);
  return repo.fetchCategories();
});

final categoryByIdProvider = Provider.family<CategoryModel?, String>((ref, id) {
  final catsAsync = ref.watch(categoriesProvider);
  return catsAsync.maybeWhen(
    data: (cats) {
      for (final c in cats) {
        if (c.id == id) return c;
      }
      return null;
    },
    orElse: () => null,
  );
});
