import 'app_localizations.dart';

extension CategoryLocalizations on AppLocalizations {
  String categoryTitle(String categoryId) {
    switch (categoryId) {
      case 'animal':
        return category_animal;
      case 'food':
        return category_food;
      case 'job':
        return category_job;
      case 'electronic':
        return category_electronic;
      case 'vehicle':
        return category_vehicle;
      default:
        return categoryId;
    }
  }
}
