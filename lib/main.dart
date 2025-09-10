import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linguess/app/router/app_router.dart';
import 'package:linguess/features/achievements/presentation/widgets/achievement_toast_widget.dart';
import 'package:linguess/features/settings/presentation/controllers/settings_controller.dart';
import 'package:linguess/firebase_options.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/core/theme/app_theme.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final adsSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (adsSupported) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes, // COPPA
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes, // EEA UAC
        maxAdContentRating: MaxAdContentRating.g, // "G" Content
      ),
    );
    await MobileAds.instance.initialize();
  }

  runApp(const ProviderScope(child: LinguessApp()));
}

class LinguessApp extends ConsumerWidget {
  const LinguessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsControllerProvider);
    final router = ref.watch(goRouterProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('${AppLocalizations.of(context)!.errorOccurred}: $e'),
      ),
      data: (settings) => MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: router,
        builder: (context, child) {
          return Stack(
            children: [
              child ?? const SizedBox(),
              const AchievementToastWidget(),
            ],
          );
        },
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
        locale: Locale(settings.appLangCode),
        supportedLocales: const [
          Locale('tr'), // Turkish
          Locale('es'), // Spanish
          Locale('de'), // German
          Locale('en'), // English
        ],
      ),
    );
  }
}
