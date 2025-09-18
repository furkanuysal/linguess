import 'package:linguess/features/game/data/models/word_model.dart';

// This extension supports both the ROOT map (`{'locales': {...}}`)
// and the direct LOCALES map (`{'en': {...}, 'tr': {...}}`).
extension LocaleMapX on Map {
  Map? _resolveLocales() {
    final maybeLocales = this['locales'];
    if (maybeLocales is Map) return maybeLocales; // root map style
    return this; // used as direct locales map
  }

  /// Returns only the term for the requested language; returns '' if not found (NO fallback).
  String termOf(String lang) {
    final locales = _resolveLocales();
    final code = lang.toLowerCase();
    final bucket = locales?[code];
    if (bucket is Map) {
      return (bucket['term'] ?? '').toString().trim();
    }
    return '';
  }

  /// Returns only the meaning for the requested language; returns null if not found (NO fallback).
  String? meaningOf(String lang) {
    final locales = _resolveLocales();
    final code = lang.toLowerCase();
    final bucket = locales?[code];
    if (bucket is Map) {
      final m = (bucket['meaning'] ?? '').toString().trim();
      return m.isEmpty ? null : m;
    }
    return null;
  }
}

extension WordModelX on WordModel {
  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'level': level,
    'locales': locales,
  };

  String pickDisplayTerm(String lang) {
    final term = locales[lang]?['term']?.trim() ?? '';
    return term;
  }
}
