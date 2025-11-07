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

  /// Button text for signing in
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// Button text for signing out
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// Message shown after successful sign out
  ///
  /// In tr, this message translates to:
  /// **'Oturum kapatıldı'**
  String get signedOut;

  /// Subtitle text prompting user to sign in to their account
  ///
  /// In tr, this message translates to:
  /// **'E-posta ve şifrenizle hesabınıza giriş yapın'**
  String get signInSubtitle;

  /// Subtitle text prompting user to sign up for a new account
  ///
  /// In tr, this message translates to:
  /// **'E-posta ve şifrenizle yeni bir hesap oluşturun'**
  String get signUpSubtitle;

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

  /// Title for the 'learn ten words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Onda On!'**
  String get achievement_learn_ten_words_title;

  /// Description for the 'learn ten words' achievement
  ///
  /// In tr, this message translates to:
  /// **'10 kelimeyi öğrendin.'**
  String get achievement_learn_ten_words_description;

  /// Title for the 'learn twenty words' achievement
  ///
  /// In tr, this message translates to:
  /// **'Yirmi Kelime!'**
  String get achievement_learn_twenty_words_title;

  /// Description for the 'learn twenty words' achievement
  ///
  /// In tr, this message translates to:
  /// **'20 kelimeyi öğrendin.'**
  String get achievement_learn_twenty_words_description;

  /// Title for the 'solve daily word' achievement
  ///
  /// In tr, this message translates to:
  /// **'Günlük Başlangıç'**
  String get achievement_solve_dailyword_first_time_title;

  /// Description for the 'solve daily word' achievement
  ///
  /// In tr, this message translates to:
  /// **'İlk kez günlük kelimeyi çözdün.'**
  String get achievement_solve_dailyword_first_time_description;

  /// Title for the 'solve daily word ten times' achievement
  ///
  /// In tr, this message translates to:
  /// **'On Günlük'**
  String get achievement_solve_dailyword_ten_times_title;

  /// Description for the 'solve daily word ten times' achievement
  ///
  /// In tr, this message translates to:
  /// **'10 kez günlük kelimeyi çözdün.'**
  String get achievement_solve_dailyword_ten_times_description;

  /// Title for the 'solve daily word thirty times' achievement
  ///
  /// In tr, this message translates to:
  /// **'Bir ay!'**
  String get achievement_solve_dailyword_thirty_times_title;

  /// Description for the 'solve daily word thirty times' achievement
  ///
  /// In tr, this message translates to:
  /// **'30 kez günlük kelimeyi çözdün.'**
  String get achievement_solve_dailyword_thirty_times_description;

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

  /// Button text for signing in with GitHub
  ///
  /// In tr, this message translates to:
  /// **'GitHub ile Giriş Yap'**
  String get signInWithGitHub;

  /// Button text for signing up with GitHub
  ///
  /// In tr, this message translates to:
  /// **'GitHub ile Kayıt Ol'**
  String get signUpWithGitHub;

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

  /// Error message shown when there is an error loading progress
  ///
  /// In tr, this message translates to:
  /// **'İlerleme yüklenirken hata oluştu'**
  String get errorLoadingProgress;

  /// Label for the learned word in the success dialog
  ///
  /// In tr, this message translates to:
  /// **'Öğrenilmiş Kelime'**
  String get learnedWordText;

  /// Message shown when the user learns a new word
  ///
  /// In tr, this message translates to:
  /// **'Kelime öğrenildi!'**
  String get theWordIsLearnedText;

  /// Encouraging message in the main menu to learn new words today
  ///
  /// In tr, this message translates to:
  /// **'Bugün yeni kelimeler öğren!'**
  String get mainMenuLearnNewWordsToday;

  /// Label for 'today' in the main menu
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get todayText;

  /// Label for the translations section
  ///
  /// In tr, this message translates to:
  /// **'Çeviriler'**
  String get translationsText;

  /// Subtitle for the category edit page
  ///
  /// In tr, this message translates to:
  /// **'Kategori adını her dil için gir. Boş bıraktıkların korunur.'**
  String get categoryEditSubtitle;

  /// Subtitle for the category add page
  ///
  /// In tr, this message translates to:
  /// **'Kategori ID\'si benzersiz olmalıdır. *zorunlu alan'**
  String get categoryAddSubtitle;

  /// Message shown when the user is in guest mode and progress is not saved
  ///
  /// In tr, this message translates to:
  /// **'Misafir olarak oynuyorsun, ilerlemen kaydedilmeyecek.'**
  String get progressNotSaved;

  /// Encouraging message to sign in or sign up to save progress
  ///
  /// In tr, this message translates to:
  /// **'Giriş yaparak altınlarını, ilerlemeni ve başarımlarını kaydet.'**
  String get signInUpsellText;

  /// Button text to continue as a guest user
  ///
  /// In tr, this message translates to:
  /// **'Misafir olarak oynamaya devam et'**
  String get continueToPlayAsGuest;

  /// Message shown when the ad is being prepared
  ///
  /// In tr, this message translates to:
  /// **'Reklam hazırlanıyor...'**
  String get preparingAd;

  /// Label for the custom game mode
  ///
  /// In tr, this message translates to:
  /// **'Özel Oyun'**
  String get customGame;

  /// Description for the custom game mode
  ///
  /// In tr, this message translates to:
  /// **'Kendi seçeneklerinle özel bir oyun oluştur.'**
  String get customGameDescription;

  /// Button text to start a custom game
  ///
  /// In tr, this message translates to:
  /// **'Özel Oyunu Başlat'**
  String get startCustomGame;

  /// Label indicating that no options are selected
  ///
  /// In tr, this message translates to:
  /// **'Hiçbiri seçilmedi'**
  String get noneSelected;

  /// Button text to clear the selection
  ///
  /// In tr, this message translates to:
  /// **'Seçimi Temizle'**
  String get clearSelection;

  /// Label showing the meaning of the word presented to the user
  ///
  /// In tr, this message translates to:
  /// **'Kelimenizin Anlamı'**
  String get meaningOfYourWord;

  /// Label for the meaning mode in the game
  ///
  /// In tr, this message translates to:
  /// **'Anlam Modu'**
  String get meaningMode;

  /// Description for the meaning mode in the game
  ///
  /// In tr, this message translates to:
  /// **'Kelimenin anlamınından kelimeyi tahmin edin.'**
  String get meaningModeDescription;

  /// The title shown when the app falls back to learned words.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get fallbackInfoTitle;

  /// Message shown when no unlearned words remain in the selected category/level.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride veya seviyede öğrenilmemiş kelime kalmadı. Öğrenilmiş kelimelerden devam ediliyor.'**
  String get fallbackInfoMessage;

  /// Message shown when absolutely no words exist in the selected category/level.
  ///
  /// In tr, this message translates to:
  /// **'Bu kategoride veya seviyede hiç kelime bulunamadı.'**
  String get noWordsFoundMessage;

  /// Label for the word
  ///
  /// In tr, this message translates to:
  /// **'Kelime'**
  String get wordText;

  /// Label for the meaning
  ///
  /// In tr, this message translates to:
  /// **'Anlam'**
  String get meaningText;

  /// Prompt to select a game mode
  ///
  /// In tr, this message translates to:
  /// **'Oyun Modu Seçin'**
  String get selectPlayMode;

  /// Error message shown when no game mode is selected
  ///
  /// In tr, this message translates to:
  /// **'Oyun modu seçilmedi'**
  String get modeNotSelected;

  /// Error message shown when no category is selected
  ///
  /// In tr, this message translates to:
  /// **'Kategori seçilmedi'**
  String get categoryNotSelected;

  /// Error message shown when no level is selected
  ///
  /// In tr, this message translates to:
  /// **'Seviye seçilmedi'**
  String get levelNotSelected;

  /// Tooltip for the button to switch to list view
  ///
  /// In tr, this message translates to:
  /// **'Liste Görünümü'**
  String get listViewTooltip;

  /// Tooltip for the button to switch to grid view
  ///
  /// In tr, this message translates to:
  /// **'Karo Görünümü'**
  String get gridViewTooltip;

  /// Error message shown when neither category nor level is selected
  ///
  /// In tr, this message translates to:
  /// **'Kategori veya seviye seçilmedi'**
  String get categoryOrLevelNotSelected;

  /// Label for the time attack game mode
  ///
  /// In tr, this message translates to:
  /// **'Zamana Karşı'**
  String get timeAttackText;

  /// Message indicating that level selection is optional
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı, yeterli sayıda kelime bulunan seviyelerden seçim yapılabilir.'**
  String get optionalLevelCanBeSelected;

  /// Message indicating that category selection is optional
  ///
  /// In tr, this message translates to:
  /// **'İsteğe bağlı, yeterli sayıda kelime bulunan kategorilerden seçim yapılabilir.'**
  String get optionalCategoryCanBeSelected;

  /// Text showing the count of correct answers
  ///
  /// In tr, this message translates to:
  /// **'Doğru Sayısı: {correctCount}'**
  String correctCountText(int correctCount);

  /// Title shown when the time attack mode ends
  ///
  /// In tr, this message translates to:
  /// **'Zamana Karşı Oyun Bitti!'**
  String get timeAttackEndedTitle;

  /// Button text to try the time attack mode again
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get tryAgainText;

  /// Button text to return to the main menu
  ///
  /// In tr, this message translates to:
  /// **'Ana Menüye Dön'**
  String get returnToMainMenu;

  /// Error message shown when there are not enough words for time attack mode
  ///
  /// In tr, this message translates to:
  /// **'Zamana karşı mod için yeterli kelime yok. Lütfen başka bir kategori veya seviye seçin.'**
  String get insufficientWordsForTimeAttack;

  /// Text showing the total gold earned
  ///
  /// In tr, this message translates to:
  /// **'Toplam Kazanılan Altın: {totalGold}'**
  String totalGoldEarned(int totalGold);

  /// Text showing the early completion bonus gold
  ///
  /// In tr, this message translates to:
  /// **'Erken Tamamlama Bonusu: {bonusGold}'**
  String earlyCompletionBonusGold(int bonusGold);

  /// Message shown when no words were solved
  ///
  /// In tr, this message translates to:
  /// **'Maalesef hiçbir kelimeyi bilemediniz.'**
  String get noWordSolvedText;

  /// Text showing consolation reward gold when player solves 0 words
  ///
  /// In tr, this message translates to:
  /// **'Teselli Ödülü: {bonusGold}'**
  String consolationRewardGold(int bonusGold);

  /// Text showing gold earned from solved words
  ///
  /// In tr, this message translates to:
  /// **'Kelimelerden Kazanılan Altın: {solvedWordsGold}'**
  String goldEarnedFromSolvedWords(int solvedWordsGold);

  /// Text showing the last solved word
  ///
  /// In tr, this message translates to:
  /// **'Son Çözülmüş Kelime: {lastSolvedWord}'**
  String lastSolvedWord(String lastSolvedWord);

  /// Text showing the last solved time
  ///
  /// In tr, this message translates to:
  /// **'Son Çözülme Zamanı: {lastSolvedAt}'**
  String lastSolvedAt(String lastSolvedAt);

  /// Text showing the count of daily words solved
  ///
  /// In tr, this message translates to:
  /// **'Çözülen Günlük Kelime Sayısı: {dailySolvedCount}'**
  String dailySolvedCount(int dailySolvedCount);

  /// Title for the statistics section
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statistictsTitle;

  /// Message shown when statistics are being loaded
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler yükleniyor...'**
  String get loadingStatistics;

  /// Message shown when there are no statistics available
  ///
  /// In tr, this message translates to:
  /// **'Mevcut istatistik yok'**
  String get noStatsAvailable;

  /// Error message shown when there is an error loading statistics
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler yüklenirken hata oluştu'**
  String get errorLoadingStats;

  /// Text showing the highest time attack score
  ///
  /// In tr, this message translates to:
  /// **'Zamana Karşı En Yüksek Skor: {timeAttackHighScore}'**
  String timeAttackHighScore(int timeAttackHighScore);

  /// Message shown when hint statistics are being loaded
  ///
  /// In tr, this message translates to:
  /// **'İpucu istatistikleri yükleniyor...'**
  String get loadingHintStats;

  /// Message shown when there are no hint statistics available
  ///
  /// In tr, this message translates to:
  /// **'Mevcut ipucu istatistiği yok'**
  String get noHintStatsAvailable;

  /// Label for the reveal letter hint statistics
  ///
  /// In tr, this message translates to:
  /// **'Harf Açma'**
  String get revealLetterHint;

  /// Label for the skip word hint statistics
  ///
  /// In tr, this message translates to:
  /// **'Kelime Atla'**
  String get skipWordTitle;

  /// Title for the hint usage statistics section
  ///
  /// In tr, this message translates to:
  /// **'İpucu Kullanımları'**
  String get hintUsageTitle;

  /// Error message shown when there is an error loading leveling data
  ///
  /// In tr, this message translates to:
  /// **'Seviye atlama verisi yüklenirken hata oluştu'**
  String get errorLoadingLevelingData;

  /// Message shown when there is no progress in leveling
  ///
  /// In tr, this message translates to:
  /// **'Seviye atlama için ilerleme yok'**
  String get noProgressInLeveling;

  /// Title for the leveling progress section
  ///
  /// In tr, this message translates to:
  /// **'Seviye İlerlemesi'**
  String get levelingProgressTitle;

  /// Text showing the percentage of the level completed
  ///
  /// In tr, this message translates to:
  /// **'%{levelPercentage} tamamlandı'**
  String levelPercentageCompleted(String levelPercentage);

  /// Title shown when the user levels up
  ///
  /// In tr, this message translates to:
  /// **'Seviye Atladın!'**
  String get levelUpTitle;

  /// SnackBar shown when admin successfully adds XP to a user.
  ///
  /// In tr, this message translates to:
  /// **'+{amount} XP eklendi!'**
  String adminXpGivenSnackBar(int amount);

  /// SnackBar shown when admin successfully resets a user's level.
  ///
  /// In tr, this message translates to:
  /// **'Level sıfırlandı!'**
  String get adminLevelResetSnackBar;

  /// Title for the button used to give XP to a user.
  ///
  /// In tr, this message translates to:
  /// **'+{amount} XP Ver'**
  String adminGiveXpButtonTitle(int amount);

  /// Description for the button that gives XP to a user.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcının mevcut XP’sine +{amount} ekler.'**
  String adminGiveXpButtonDesc(int amount);

  /// Title for the button used to reset a user's level to the starting level (Level 1).
  ///
  /// In tr, this message translates to:
  /// **'Level 1’e Sıfırla'**
  String get adminResetLevelToOneButtonTitle;

  /// Description for the button that resets a user's level to 1, specifying the resulting values.
  ///
  /// In tr, this message translates to:
  /// **'Level=1, XP=95, totalXp=95 olarak ayarlar.'**
  String get adminResetLevelToOneButtonDesc;

  /// Title for the button used to clear the locally cached 'last_level' value.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı last_level\'ı Temizle'**
  String get adminClearLastLevelCacheButtonTitle;

  /// Description for the button that clears the 'last_level' from local storage (SharedPreferences).
  ///
  /// In tr, this message translates to:
  /// **'SharedPreferences içindeki kayıtlı last_level silinir.'**
  String get adminClearLastLevelCacheButtonDesc;

  /// SnackBar shown when the local 'last_level' cache is successfully cleared.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı last_level temizlendi!'**
  String get adminLastLevelCacheClearedSnackBar;

  /// Title for the button used to clear all local data (SharedPreferences).
  ///
  /// In tr, this message translates to:
  /// **'Tüm Yerel Verileri Temizle'**
  String get adminClearAllLocalDataButtonTitle;

  /// Description for the button that clears ALL local data, highlighting that it is irreversible.
  ///
  /// In tr, this message translates to:
  /// **'SharedPreferences içindeki TÜM veriler silinir. (Geri alınamaz)'**
  String get adminClearAllLocalDataButtonDesc;

  /// Title for the confirmation dialog shown before clearing all local data.
  ///
  /// In tr, this message translates to:
  /// **'Emin misiniz?'**
  String get adminClearAllConfirmationTitle;

  /// Description in the confirmation dialog warning the user that all local data will be permanently lost.
  ///
  /// In tr, this message translates to:
  /// **'Tüm yerel veriler (ayarlar, seviye, cache vb.) kalıcı olarak silinecek. Bu işlem geri alınamaz!'**
  String get adminClearAllConfirmationDesc;

  /// Text for the button that executes the 'Clear All Local Data' action in the confirmation dialog.
  ///
  /// In tr, this message translates to:
  /// **'Verileri Temizle'**
  String get adminClearAllButtonText;

  /// SnackBar shown when all local data is successfully cleared.
  ///
  /// In tr, this message translates to:
  /// **'Tüm yerel veriler temizlendi!'**
  String get adminAllLocalDataClearedSnackBar;

  /// SnackBar shown when there is an error during the process of clearing all local data.
  ///
  /// In tr, this message translates to:
  /// **'Yerel veriler temizlenirken hata oluştu'**
  String get adminClearAllLocalDataErrorSnackBar;

  /// Error message shown when a permission request is denied
  ///
  /// In tr, this message translates to:
  /// **'İzin reddedildi'**
  String get errorPermissionDenied;

  /// Error message shown when the user's session has expired
  ///
  /// In tr, this message translates to:
  /// **'Oturum süresi doldu, lütfen tekrar giriş yapın'**
  String get errorSessionExpired;

  /// Error message shown when the user's session is invalid
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz oturum, lütfen tekrar giriş yapın'**
  String get errorInvalidSession;

  /// Error message shown when the profile update process fails
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellemesi başarısız'**
  String get errorProfileUpdateFailed;

  /// Error message shown when a sensitive operation requires recent login
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yakın zamanda giriş yapmanız gerekiyor'**
  String get errorRequiresRecentLogin;

  /// Error message shown when the password change process fails
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştirme başarısız'**
  String get errorChangePasswordFailed;

  /// Error message shown when the new password and confirm password do not match
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor!'**
  String get errorPasswordsDoNotMatch;

  /// Message shown when the password is changed successfully
  ///
  /// In tr, this message translates to:
  /// **'Şifre başarıyla değiştirildi!'**
  String get passwordChangeSuccessful;

  /// Message shown when the profile is updated successfully
  ///
  /// In tr, this message translates to:
  /// **'Profil başarıyla güncellendi!'**
  String get profileUpdateSuccessful;

  /// Title for the account settings page
  ///
  /// In tr, this message translates to:
  /// **'Hesap Ayarları'**
  String get accountSettingsTitle;

  /// Title for the personal information section
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Bilgiler'**
  String get personalInfoTitle;

  /// Label for the display name input field
  ///
  /// In tr, this message translates to:
  /// **'Görünen Ad'**
  String get displayNameLabel;

  /// Label for the account creation date
  ///
  /// In tr, this message translates to:
  /// **'Katılma Tarihi'**
  String get createdAtLabel;

  /// Title for the password update section
  ///
  /// In tr, this message translates to:
  /// **'Şifre Güncelleme'**
  String get passwordUpdateTitle;

  /// Label for the current password input field
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Şifre'**
  String get currentPasswordLabel;

  /// Label for the new password input field
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPasswordLabel;

  /// Label for the confirm new password input field
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre (Tekrar)'**
  String get confirmNewPasswordLabel;

  /// Label for the button to update the password
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get updatePasswordLabel;

  /// Error message shown when trying to change the password of an account created with an external provider
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap bir dış sağlayıcı (ör. Google, GitHub) ile oluşturulduğu için şifre değiştirilemez.'**
  String get externalProviderPasswordChangeDisabled;

  /// Subtitle for the account settings page
  ///
  /// In tr, this message translates to:
  /// **'Hesap bilgilerinizi ve şifrenizi yönetin.'**
  String get accountSettingsSubtitle;

  /// Title for the in-app shop
  ///
  /// In tr, this message translates to:
  /// **'Mağaza'**
  String get shopTitle;

  /// Label for the buy button in the shop
  ///
  /// In tr, this message translates to:
  /// **'Satın Al'**
  String get buyLabel;

  /// Label for the equip button in the shop
  ///
  /// In tr, this message translates to:
  /// **'Kuşan'**
  String get equipLabel;

  /// Label indicating that an item is currently equipped
  ///
  /// In tr, this message translates to:
  /// **'Kuşanıldı'**
  String get equippedLabel;

  /// Message shown when a purchase is successful
  ///
  /// In tr, this message translates to:
  /// **'Satın alma işlemi başarılı!'**
  String get purchaseSuccessful;
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
