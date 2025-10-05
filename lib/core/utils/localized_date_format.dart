import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';

String localizedDate(BuildContext context, WidgetRef ref) {
  final settings = ref.read(settingsControllerProvider).value;
  // ex: "tr", "en", "de" -> "tr", "en", "de"
  // DateFormat locale takes a languageCode or BCP-47 tag.
  final localeTag =
      settings?.appLangCode ?? Localizations.localeOf(context).toLanguageTag();

  // yMMMMEEEEd -> “5 Ekim 2025 Pazar” / “Sunday, October 5, 2025”
  return DateFormat.yMMMMEEEEd(localeTag).format(DateTime.now());
}
