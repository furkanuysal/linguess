import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

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

  /// Category label for jobs
  ///
  /// In tr, this message translates to:
  /// **'Meslekler'**
  String get category_job;

  /// Category label for electronics
  ///
  /// In tr, this message translates to:
  /// **'Elektronik'**
  String get category_electronic;

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
  String get signIn;

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
  String get signUpButtonText;

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
  String get signUp;

  /// Message shown after successful registration
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Giriş yapabilirsiniz.'**
  String get signUpSuccess;

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

  /// Label for the setting to enable or disable dark mode
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Mod'**
  String get settingsDarkMode;

  /// Label for the main menu where the user selects a game mode
  ///
  /// In tr, this message translates to:
  /// **'Bir oyun türü seçin'**
  String get mainMenuPlayModeSelection;

  /// Error message shown when the user has insufficient gold
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz Altın'**
  String get insufficientGold;

  /// Alert message shown when the daily word is completed
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kelime Tamamlandı'**
  String get dailyWordCompletedTitleAlert;

  /// Body message shown when the daily word is completed
  ///
  /// In tr, this message translates to:
  /// **'Bugünün kelimesini çözdünüz. Yeni kelime yarın!'**
  String get dailyWordCompletedBodyAlert;

  /// 'Okay' button text for alerts or confirmations
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get okay;

  /// Error message shown when email is required
  ///
  /// In tr, this message translates to:
  /// **'E-posta alanı boş bırakılamaz!'**
  String get emailRequired;

  /// Error message shown when password is required
  ///
  /// In tr, this message translates to:
  /// **'Şifre alanı boş bırakılamaz!'**
  String get passwordRequired;

  /// Error message shown when sign-up fails
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız'**
  String get errorSignUpFailed;

  /// Error message shown when the password is too weak
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf'**
  String get errorWeakPassword;

  /// Error message shown when the email is already in use
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta zaten kullanılıyor!'**
  String get errorEmailAlreadyInUse;

  /// Error message shown when the user is not found
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı.'**
  String get errorUserNotFound;

  /// Error message shown when there are too many requests
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.'**
  String get errorTooManyRequests;

  /// Error message shown when the password is wrong
  ///
  /// In tr, this message translates to:
  /// **'Yanlış şifre!'**
  String get errorWrongPassword;

  /// Error message shown when the email is invalid
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz e-posta adresi!'**
  String get errorInvalidEmail;

  /// Error message shown when there is a network error
  ///
  /// In tr, this message translates to:
  /// **'Ağ hatası. Lütfen internet bağlantınızı kontrol edin.'**
  String get errorNetwork;

  /// Message shown when sign-in is successful
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarılı!'**
  String get successSignIn;

  /// Message shown when registration is successful
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı!'**
  String get successSignUp;

  /// Error message shown when the credentials are invalid
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya parola hatalı!'**
  String get errorInvalidCredential;

  /// Message shown when the password reset email is sent successfully
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama e-postası gönderildi!'**
  String get successResetPasswordEmailSent;

  /// Label for the button to send the password reset link
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama bağlantısı gönder'**
  String get sendResetLink;

  /// Label for the forgot password link
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi mi unuttunuz?'**
  String get forgotPassword;

  /// Label for the reset password button
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Sıfırla'**
  String get resetPassword;

  /// Label for the total word count
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kelime'**
  String get totalWordText;

  /// Label for the loading indicator
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loadingText;

  /// Label for the total learned word count
  ///
  /// In tr, this message translates to:
  /// **'Toplam Öğrenilen Kelime'**
  String get totalLearnedWordsText;

  /// Label for the achievements section
  ///
  /// In tr, this message translates to:
  /// **'Başarımlar'**
  String get achievements;

  /// Label for the 'view all' button
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get viewAll;

  /// Label for the 'coming soon' message
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get comingSoon;

  /// Message shown when the user needs to sign in to solve the daily word
  ///
  /// In tr, this message translates to:
  /// **'Günlük kelimeyi çözmek için giriş yapmalısınız.'**
  String get dailyWordSignInRequired;

  /// Title for the 'solve first word' achievement
  ///
  /// In tr, this message translates to:
  /// **'Her şey bir kelimeyle başlar'**
  String get achievement_solve_firstword_title;

  /// Description for the 'solve first word' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez bir kelimeyi çözdün.'**
  String get achievement_solve_firstword_description;

  /// Title for the 'learn first word' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk Kelime!'**
  String get achievement_learn_firstword_title;

  /// Description for the 'learn first word' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez bir kelimeyi öğrendin.'**
  String get achievement_learn_firstword_description;

  /// Title for the 'solve daily word' achievement
  ///
  /// In tr, this message translates to:
  /// **'Günlük Başlangıç'**
  String get achievement_solve_dailyword_firsttime_title;

  /// Description for the 'solve daily word' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez günlük kelimeyi çözdün.'**
  String get achievement_solve_dailyword_firsttime_description;

  /// Title for the 'solve first word without hint' achievement
  ///
  /// In tr, this message translates to:
  /// **'Kopya çekmeden!'**
  String get achievement_solve_firstword_nohint_title;

  /// Description for the 'solve first word without hint' achievement
  ///
  /// In tr, this message translates to:
  /// **'Bir kelimeyi hiç ipucu kullanmadan çözdün.'**
  String get achievement_solve_firstword_nohint_description;

  /// Message shown when an achievement is unlocked
  ///
  /// In tr, this message translates to:
  /// **'Başarım kazanıldı!'**
  String get achievementUnlockedText;

  /// Label for an unknown achievement
  ///
  /// In tr, this message translates to:
  /// **'Bilinmeyen Başarım'**
  String get unknownAchievementTitleText;

  /// Description for an unknown achievement
  ///
  /// In tr, this message translates to:
  /// **'Bu başarı hakkında bilgi yok.'**
  String get unknownAchievementDescriptionText;

  /// Title for the 'solve ten words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Onun gücü!'**
  String get achievement_solve_ten_words_title;

  /// Description for the 'solve ten words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla 10 kelime çözdün!'**
  String get achievement_solve_ten_words_description;

  /// Title for the 'solve fifty words' achievement
  ///
  /// In tr, this message translates to:
  /// **'50\'lik zafer!'**
  String get achievement_solve_fifty_words_title;

  /// Description for the 'solve fifty words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla 50 kelime çözdün!'**
  String get achievement_solve_fifty_words_description;

  /// Title for the 'solve hundred words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Kelime Yüzbaşısı'**
  String get achievement_solve_hundred_words_title;

  /// Description for the 'solve hundred words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla 100 kelime çözdün!'**
  String get achievement_solve_hundred_words_description;

  /// Title for the 'solve five hundred words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Beş Yüzlü Bilge'**
  String get achievement_solve_fivehundred_words_title;

  /// Description for the 'solve five hundred words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla 500 kelime çözdün!'**
  String get achievement_solve_fivehundred_words_description;

  /// Title for the 'solve thousand words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Binbaşı Kelime Uzmanı'**
  String get achievement_solve_thousand_words_title;

  /// Description for the 'solve thousand words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla 1000 kelime çözdün!'**
  String get achievement_solve_thousand_words_description;

  /// Title for the 'used definition powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'Ansiklopediyi aç'**
  String get achievement_used_definition_powerup_first_time_title;

  /// Description for the 'used definition powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez tanım güçlendiricisini kullandın.'**
  String get achievement_used_definition_powerup_first_time_description;

  /// Title for the 'used hint powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'Ufak kopya'**
  String get achievement_used_hint_powerup_first_time_title;

  /// Description for the 'used hint powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez ipucu güçlendiricisini kullandın.'**
  String get achievement_used_hint_powerup_first_time_description;

  /// Title for the 'used skip powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'Hızlı atla'**
  String get achievement_used_skip_powerup_first_time_title;

  /// Description for the 'used skip powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez atlama güçlendiricisini kullandın.'**
  String get achievement_used_skip_powerup_first_time_description;

  /// Title for the 'used example sentence powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'Cümlelerle güçlen'**
  String get achievement_used_example_sentence_powerup_first_time_title;

  /// Description for the 'used example sentence powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez örnek cümle güçlendiricisini kullandın.'**
  String get achievement_used_example_sentence_powerup_first_time_description;

  /// Title for the 'used example sentence target powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'Hedef dilde örnekler'**
  String get achievement_used_example_sentence_target_powerup_first_time_title;

  /// Description for the 'used example sentence target powerup first time' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez hedef dilde örnek cümle güçlendiricisini kullandın.'**
  String
  get achievement_used_example_sentence_target_powerup_first_time_description;

  /// Error message shown when the ad is not ready
  ///
  /// In tr, this message translates to:
  /// **'Reklam hazır değil. Biraz sonra tekrar deneyin.'**
  String get adNotReady;

  /// Error message shown when the ad is not loaded
  ///
  /// In tr, this message translates to:
  /// **'Reklam gösterilemiyor.'**
  String get adNotLoaded;

  /// The message shown when the user earns gold from watching an ad
  ///
  /// In tr, this message translates to:
  /// **'Reklam ödülü olarak {gold} altın kazandınız!'**
  String adRewardGoldEarned(int gold);

  /// Tooltip shown when the user can earn gold by watching an ad
  ///
  /// In tr, this message translates to:
  /// **'Reklam ödülü'**
  String get adRewardTooltip;

  /// Label for the app language setting
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get appLanguage;

  /// Label for the target language setting
  ///
  /// In tr, this message translates to:
  /// **'Hedef Dil'**
  String get targetLanguage;

  /// Description text for the category selection card
  ///
  /// In tr, this message translates to:
  /// **'Farklı kelime kategorilerinden birini seçin'**
  String get selectCategoryDescription;

  /// Description text for the level selection card
  ///
  /// In tr, this message translates to:
  /// **'Zorluk seviyenizi seçin'**
  String get selectLevelDescription;

  /// Description text for the daily word challenge card
  ///
  /// In tr, this message translates to:
  /// **'Bugünün özel meydan okuması'**
  String get dailyWordDescription;

  /// Title for the ad reward confirmation dialog
  ///
  /// In tr, this message translates to:
  /// **'Reklam ödülü!'**
  String get adRewardConfirmTitle;

  /// Body for the ad reward confirmation dialog
  ///
  /// In tr, this message translates to:
  /// **'Reklamı izleyerek {gold} altın kazanabilirsiniz.'**
  String adRewardConfirmBody(int gold);

  /// Label for the cancel button in the confirmation dialog
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancelText;

  /// Label for the watch ad button in the confirmation dialog
  ///
  /// In tr, this message translates to:
  /// **'Reklamı İzle'**
  String get watchAdText;

  /// Label for the option to overwrite existing entries
  ///
  /// In tr, this message translates to:
  /// **'Mevcutsa Üzerine Yaz'**
  String get overwriteIfExists;

  /// Label for the save button
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get saveText;

  /// Error message shown when a non-admin user tries to access the admin page
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca yöneticiler erişebilir.'**
  String get errorOnlyAdminsCanAccess;

  /// Validation message indicating a required field
  ///
  /// In tr, this message translates to:
  /// **'Gerekli'**
  String get requiredText;

  /// Error message shown when category and level are not selected
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir kategori ve seviye seçin.'**
  String get chooseCategoryAndLevel;

  /// Title for the admin page to add or update words
  ///
  /// In tr, this message translates to:
  /// **'Kelime Ekle / Güncelle'**
  String get addUpdateWordTitle;

  /// Message shown when there are no daily entries
  ///
  /// In tr, this message translates to:
  /// **'Günlük kelimelere ait giriş yok'**
  String get noDailyEntries;

  /// Label for the daily entries list
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kelime Listesi'**
  String get dailyListText;

  /// Title for the delete word confirmation dialog
  ///
  /// In tr, this message translates to:
  /// **'Kelime Sil'**
  String get deleteWordText;

  /// Body for the delete word confirmation dialog
  ///
  /// In tr, this message translates to:
  /// **'Kelime \'{word}\' silinsin mi?'**
  String deleteWordBody(String word);

  /// Message shown when a word is deleted successfully
  ///
  /// In tr, this message translates to:
  /// **'Kelime başarıyla silindi.'**
  String get wordSuccessfullyDeleted;

  /// Label for the button to add a new word
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kelime Ekle'**
  String get addWordTitle;

  /// Label for the button to update an existing word
  ///
  /// In tr, this message translates to:
  /// **'Kelime Güncelle'**
  String get updateWordText;

  /// Label for the 'all' option in filters
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get allText;

  /// Placeholder text for the search input to find words in English
  ///
  /// In tr, this message translates to:
  /// **'Kelimeyi Ara (İngilizce)'**
  String get searchTheWordEnglish;

  /// Label for the button to clear the search input
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clearText;

  /// Message shown when no words match the search criteria
  ///
  /// In tr, this message translates to:
  /// **'Hiç kelime bulunamadı'**
  String get noWordsFound;

  /// Label for the words list in the admin panel
  ///
  /// In tr, this message translates to:
  /// **'Kelime Listesi'**
  String get wordsListText;

  /// Description text for the add word card
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir kelime girişi oluştur'**
  String get addWordDesc;

  /// Description text for the words list card
  ///
  /// In tr, this message translates to:
  /// **'Mevcut kelimeleri görüntüle ve yönet'**
  String get wordsListDesc;

  /// Description text for the daily list card
  ///
  /// In tr, this message translates to:
  /// **'Günlük kelime seçimlerini görüntüle'**
  String get dailyListDesc;

  /// Title for the admin panel page
  ///
  /// In tr, this message translates to:
  /// **'Admin Panel'**
  String get adminPanelTitle;

  /// Message shown when a word is saved successfully
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla kaydedildi'**
  String get savedSuccessfully;

  /// Title for the categories management page
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get categoriesText;

  /// Description text for the categories list card
  ///
  /// In tr, this message translates to:
  /// **'Mevcut kategorileri görüntüle ve yönet'**
  String get categoryListDesc;

  /// Label for the button to manage categories
  ///
  /// In tr, this message translates to:
  /// **'Kategorileri Yönet'**
  String get manageCategories;

  /// Label for the button to add a new category
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori Ekle'**
  String get addCategory;

  /// Tooltip for the button to move a category up in the list
  ///
  /// In tr, this message translates to:
  /// **'Yukarı Taşı'**
  String get moveUpText;

  /// Tooltip for the button to move a category down in the list
  ///
  /// In tr, this message translates to:
  /// **'Aşağı Taşı'**
  String get moveDownText;

  /// Label for the button to update a category
  ///
  /// In tr, this message translates to:
  /// **'Kategori Güncelle'**
  String get updateCategoryText;

  /// Label for the button to delete a category
  ///
  /// In tr, this message translates to:
  /// **'Kategori Sil'**
  String get deleteCategoryText;

  /// Label for the category ID input field in the category form
  ///
  /// In tr, this message translates to:
  /// **'Kategori ID\'si (kısa ad, değiştirilemez)'**
  String get categoryIdFormLabel;

  /// Label for the category icon input field in the category form
  ///
  /// In tr, this message translates to:
  /// **'Kategori Simgesi (Material icon codePoint, opsiyonel)'**
  String get categoryIconFormLabel;

  /// Confirmation message shown when deleting a category
  ///
  /// In tr, this message translates to:
  /// **'Kategori \'{id}\' silinsin mi?'**
  String deleteCategoryConfirmation(String id);

  /// Message shown when a category is deleted successfully
  ///
  /// In tr, this message translates to:
  /// **'Kategori başarıyla silindi.'**
  String get categorySuccessfullyDeleted;

  /// Message shown when the user tries to use a power-up in daily mode
  ///
  /// In tr, this message translates to:
  /// **'Günlük modda bu güçlendirici kullanılamaz.'**
  String get thisPowerUpNotAllowedInDaily;

  /// Tooltip shown when all letters have already been revealed
  ///
  /// In tr, this message translates to:
  /// **'Tüm harfler zaten açıldı'**
  String get allLettersRevealed;

  /// Tooltip shown for the skip to next power-up
  ///
  /// In tr, this message translates to:
  /// **'Sonraki kelimeye atla'**
  String get skipToNext;

  /// Tooltip shown when there is nothing to skip
  ///
  /// In tr, this message translates to:
  /// **'Atlanacak kelime yok'**
  String get nothingToSkip;

  /// Label for the meaning of the word
  ///
  /// In tr, this message translates to:
  /// **'Kelime Anlamı'**
  String get wordMeaningText;

  /// Button text for signing in with Google
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get signInWithGoogle;

  /// Button text for signing up with Google
  ///
  /// In tr, this message translates to:
  /// **'Google ile Kayıt Ol'**
  String get signUpWithGoogle;

  /// Text to separate different sign-in options
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get orText;

  /// Label for the button to show the password
  ///
  /// In tr, this message translates to:
  /// **'Göster'**
  String get showText;

  /// Label for the button to hide the password
  ///
  /// In tr, this message translates to:
  /// **'Gizle'**
  String get hideText;

  /// Message shown when the sign-in process is canceled by the user
  ///
  /// In tr, this message translates to:
  /// **'Giriş iptal edildi'**
  String get signInCanceled;

  /// Message shown when the sign-up process is canceled by the user
  ///
  /// In tr, this message translates to:
  /// **'Kayıt iptal edildi'**
  String get signUpCanceled;

  /// Message showing the email of the signed-in user
  ///
  /// In tr, this message translates to:
  /// **'{email} olarak giriş yapıldı'**
  String signedInAs(String email);

  /// Message showing the email of the signed-up user
  ///
  /// In tr, this message translates to:
  /// **'{email} olarak kayıt olundu'**
  String signedUpAs(String email);

  /// Error message shown when the password reset process fails
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama başarısız'**
  String get errorResetPasswordFailed;

  /// Tooltip for the button to show the word definition
  ///
  /// In tr, this message translates to:
  /// **'Tanımı Göster'**
  String get showDefinition;

  /// Message shown when there is no definition to display
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek bir tanım yok'**
  String get noDefinitionToShow;

  /// Title for the definition hint dialog
  ///
  /// In tr, this message translates to:
  /// **'Kelime Tanımı'**
  String get definitionHintTitle;

  /// Label for the example sentence of the word
  ///
  /// In tr, this message translates to:
  /// **'Örnek Cümle'**
  String get exampleSentenceText;

  /// Tooltip for the button to show the example sentence
  ///
  /// In tr, this message translates to:
  /// **'Örnek cümleyi göster'**
  String get exampleSentenceHint;

  /// Message shown when there is no example sentence to display
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek bir örnek cümle yok'**
  String get noExampleSentenceToShow;

  /// Tooltip for the button to show the example sentence
  ///
  /// In tr, this message translates to:
  /// **'Hedef dilde örnek cümleyi göster'**
  String get exampleSentenceTargetHint;

  /// Message shown when there is no example sentence to display
  ///
  /// In tr, this message translates to:
  /// **'Hedef dilde gösterilecek bir örnek cümle yok'**
  String get noExampleSentenceTargetToShow;

  /// Title for the example sentence in the target language dialog
  ///
  /// In tr, this message translates to:
  /// **'Hedef Dilde Örnek Cümle'**
  String get exampleSentenceTargetTitle;
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
      <String>['de', 'en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
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
