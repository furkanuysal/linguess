import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:linguess/features/home/home_selector.dart';
import 'package:linguess/features/settings/settings_controller.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linguess/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: LinguessApp()));
}

class LinguessApp extends ConsumerWidget {
  const LinguessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsControllerProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
      ),
      data: (settings) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr'), // Turkish
          Locale('es'), // Spanish
          Locale('de'), // German
        ],
        home: const HomeSelector(),
      ),
    );
  }
}
