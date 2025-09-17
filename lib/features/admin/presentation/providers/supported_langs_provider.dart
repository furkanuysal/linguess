import 'package:flutter_riverpod/flutter_riverpod.dart';

// Default languages to be used in the admin panel
final supportedLangsProvider = Provider<List<String>>(
  (_) => const ['en', 'tr', 'de', 'es'],
);

// Language labels (UI label)
final languageLabelsProvider = Provider<Map<String, String>>(
  (_) => const {
    'en': 'English',
    'tr': 'Turkish',
    'de': 'German',
    'es': 'Spanish',
  },
);
