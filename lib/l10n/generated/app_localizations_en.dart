// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Linguess';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get dailyWord => 'Daily Word';

  @override
  String get settings => 'Settings';

  @override
  String get category => 'Category';

  @override
  String get category_food => 'Food';

  @override
  String get category_animal => 'Animals';

  @override
  String get category_job => 'Jobs';

  @override
  String get category_electronic => 'Electronics';

  @override
  String get category_vehicle => 'Vehicles';

  @override
  String get nextWord => 'Next Word';

  @override
  String get checkAnswer => 'Check Answer';

  @override
  String get letterHint => 'Hint';

  @override
  String get yourWord => 'Your Word';

  @override
  String get level => 'Level';

  @override
  String get translation => 'Translation';

  @override
  String get close => 'Close';

  @override
  String get login => 'Log In';

  @override
  String get logout => 'Log Out';

  @override
  String get profile => 'Profile';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get correctText => 'Correct';

  @override
  String get registerButtonText => 'Don\'t have an account? Sign up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get register => 'Register';

  @override
  String get registerSuccess => 'Registration successful! You can log in now.';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters long';

  @override
  String get gold => 'Gold';

  @override
  String get learnedWordsText => 'Learned Words';

  @override
  String get learnedWordsEmpty => 'No words learned yet';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get noDataToShow => 'No data to show';

  @override
  String get errorSignInFailed => 'Sign-in failed';

  @override
  String get wordCount => 'Word Count';

  @override
  String get settingsLearnedWords => 'Show learned words again';

  @override
  String get settingsSoundEffects => 'Sound Effects';

  @override
  String get learnedCountText => 'Words Learned';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get mainMenuPlayModeSelection => 'Select a game mode';

  @override
  String get insufficientGold => 'Insufficient Gold';

  @override
  String get dailyWordCompletedTitleAlert => 'Daily Word Completed';

  @override
  String get dailyWordCompletedBodyAlert =>
      'You solved today\'s word. A new word will be available tomorrow!';

  @override
  String get okay => 'Okay';

  @override
  String get emailRequired => 'Email field cannot be empty!';

  @override
  String get passwordRequired => 'Password field cannot be empty!';

  @override
  String get errorSignUpFailed => 'Sign-up failed';

  @override
  String get errorWeakPassword => 'Password is too weak';

  @override
  String get errorEmailAlreadyInUse => 'This email is already in use!';

  @override
  String get errorUserNotFound => 'User not found.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts have been made. Please try again later.';

  @override
  String get errorWrongPassword => 'Wrong password!';

  @override
  String get errorInvalidEmail => 'Invalid email address!';

  @override
  String get errorNetwork =>
      'Network error. Please check your internet connection.';

  @override
  String get successSignIn => 'Sign-in successful!';

  @override
  String get successRegister => 'Registration successful!';

  @override
  String get errorInvalidCredential => 'Email or password is incorrect!';

  @override
  String get successResetPasswordEmailSent => 'Password reset email sent!';

  @override
  String get sendResetLink => 'Send Password Reset Link';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get totalWordText => 'Total Words';

  @override
  String get loadingText => 'Loading...';

  @override
  String get totalLearnedWordsText => 'Total Learned Words';

  @override
  String get achievements => 'Achievements';

  @override
  String get viewAll => 'View All';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get dailyWordLoginRequired =>
      'You must be logged in to solve the daily word.';

  @override
  String get achievement_learn_firstword_title => 'First Word!';

  @override
  String get achievement_learn_firstword_description =>
      'You learned a word for the first time.';

  @override
  String get achievement_solve_dailyword_firsttime_title => 'Daily Start';

  @override
  String get achievement_solve_dailyword_firsttime_description =>
      'You solved the daily word for the first time.';

  @override
  String get achievement_solve_firstword_nohint_title => 'No hint!';

  @override
  String get achievement_solve_firstword_nohint_description =>
      'You solved a word without using any hints.';

  @override
  String get achievementUnlockedText => 'Achievement Unlocked!';

  @override
  String get unknownAchievementTitleText => 'Unknown Achievement';

  @override
  String get unknownAchievementDescriptionText =>
      'No information available about this achievement.';

  @override
  String get achievement_solve_ten_words_title => 'Tenten!';

  @override
  String get achievement_solve_ten_words_description =>
      'You solved 10 words successfully!';

  @override
  String get achievement_solve_fifty_words_title => 'Half hundred!';

  @override
  String get achievement_solve_fifty_words_description =>
      'You solved 50 words successfully!';

  @override
  String get achievement_solve_hundred_words_title => '100%';

  @override
  String get achievement_solve_hundred_words_description =>
      'You solved 100 words successfully!';

  @override
  String get achievement_solve_fivehundred_words_title => 'Half thousand!';

  @override
  String get achievement_solve_fivehundred_words_description =>
      'You solved 500 words successfully!';

  @override
  String get achievement_solve_thousand_words_title => 'Thousand!';

  @override
  String get achievement_solve_thousand_words_description =>
      'You solved 1000 words successfully!';

  @override
  String get adNotReady => 'Ad not ready. Please try again later.';

  @override
  String get adNotLoaded => 'Ad could not be loaded.';

  @override
  String adRewardGoldEarned(int gold) {
    return 'You earned $gold gold as an ad reward!';
  }

  @override
  String get adRewardTooltip => 'Ad reward';

  @override
  String get appLanguage => 'App Language';

  @override
  String get targetLanguage => 'Target Language';

  @override
  String get selectCategoryDescription =>
      'Choose from different word categories';

  @override
  String get selectLevelDescription => 'Choose your difficulty level';

  @override
  String get dailyWordDescription => 'Today\'s special challenge';
}
