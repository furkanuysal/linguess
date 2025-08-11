import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// The name of the application
  ///
  /// In tr, this message translates to:
  /// **'Linguess'**
  String get appTitle;

  /// Button or label text prompting user to choose a category
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seçin'**
  String get selectCategory;

  /// Button or label text prompting user to choose a difficulty level
  ///
  /// In tr, this message translates to:
  /// **'Seviye Seçin'**
  String get selectLevel;

  /// Label for the daily word challenge
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kelime'**
  String get dailyWord;

  /// Label for the settings option
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// Label for the category selection
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// Category label for food
  ///
  /// In tr, this message translates to:
  /// **'Yiyecekler'**
  String get category_food;

  /// Category label for animals
  ///
  /// In tr, this message translates to:
  /// **'Hayvanlar'**
  String get category_animal;

  /// Category label for vehicles
  ///
  /// In tr, this message translates to:
  /// **'Araçlar'**
  String get category_vehicle;

  /// Button text to load the next word in the game
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Kelime'**
  String get nextWord;

  /// Button text to check the user's answer
  ///
  /// In tr, this message translates to:
  /// **'Cevabı Kontrol Et'**
  String get checkAnswer;

  /// Hint text for the letter input
  ///
  /// In tr, this message translates to:
  /// **'İpucu'**
  String get letterHint;

  /// 'Your word' label for the asked word in the game
  ///
  /// In tr, this message translates to:
  /// **'Kelimeniz'**
  String get yourWord;

  /// 'Level' label for the difficulty of the word
  ///
  /// In tr, this message translates to:
  /// **'Seviye'**
  String get level;

  /// 'Translation' label for the translation of the word
  ///
  /// In tr, this message translates to:
  /// **'Çeviri'**
  String get translation;

  /// 'Close' button text for dialogs or pop-ups
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// Button text for logging in
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// Button text for logging out
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// Label for the user profile section
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// Label for the 'correct answer' in the game
  ///
  /// In tr, this message translates to:
  /// **'Doğru Cevap'**
  String get correctAnswer;

  /// Word that means 'correct' in the game context
  ///
  /// In tr, this message translates to:
  /// **'Doğru'**
  String get correctText;

  /// Text for the button to navigate to the registration page
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get registerButtonText;

  /// Label for the email input field
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// Label for the password input field
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// Button text for registering a new user
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// Message shown after successful registration
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Giriş yapabilirsiniz.'**
  String get registerSuccess;

  /// Error message for invalid email format
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi'**
  String get invalidEmail;

  /// Error message for password that is too short
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 6 karakter olmalıdır'**
  String get passwordTooShort;

  /// Label for the user's gold amount in the profile
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get gold;

  /// Label for the list of words learned by the user
  ///
  /// In tr, this message translates to:
  /// **'Öğrenilen Kelimeler'**
  String get learnedWordsText;

  /// Message shown when the user has no learned words
  ///
  /// In tr, this message translates to:
  /// **'Henüz öğrenilen kelime yok'**
  String get learnedWordsEmpty;

  /// Generic error message shown when an error occurs
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get errorOccurred;

  /// Message shown when there is no data to display
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek veri yok'**
  String get noDataToShow;

  /// Error message shown when sign-in fails
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız'**
  String get errorSignInFailed;

  /// Label for the number of words in a category or level
  ///
  /// In tr, this message translates to:
  /// **'Kelime Sayısı'**
  String get wordCount;

  /// Label for the setting to repeat learned words
  ///
  /// In tr, this message translates to:
  /// **'Öğrenilen kelimeleri tekrar göster'**
  String get settingsLearnedWords;

  /// Label for the setting to enable or disable sound effects
  ///
  /// In tr, this message translates to:
  /// **'Ses efektleri'**
  String get settingsSoundEffects;

  /// Label for the count of learned words in a level or category
  ///
  /// In tr, this message translates to:
  /// **'Kelime Öğrenildi'**
  String get learnedCountText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
