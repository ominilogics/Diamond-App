import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No worries. Enter your email and we\'ll send you a link to\nreset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email here.'**
  String get emailHint;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get rememberPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your favorite cards, saved drafts, and\npersonal collections.'**
  String get loginSubtitle;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password here.'**
  String get passwordHint;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUpText.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpText;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join and start creating meaningful moments with\nbeautiful cards for every occasion.'**
  String get signUpSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name here.'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password again.'**
  String get confirmPasswordHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'   Someone\'s smile could start with a card from you today.'**
  String get welcomeSubtitle;

  /// No description provided for @featuredCards.
  ///
  /// In en, this message translates to:
  /// **'Featured Cards'**
  String get featuredCards;

  /// No description provided for @eidCard1.
  ///
  /// In en, this message translates to:
  /// **'Eid Card 1'**
  String get eidCard1;

  /// No description provided for @cardsScreen.
  ///
  /// In en, this message translates to:
  /// **'Cards Screen'**
  String get cardsScreen;

  /// No description provided for @favoriteScreen.
  ///
  /// In en, this message translates to:
  /// **'Favorite Screen'**
  String get favoriteScreen;

  /// No description provided for @settingsScreen.
  ///
  /// In en, this message translates to:
  /// **'Settings Screen'**
  String get settingsScreen;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @love.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get love;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get thankYou;

  /// No description provided for @anniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get anniversary;

  /// No description provided for @islamicCards.
  ///
  /// In en, this message translates to:
  /// **'Islamic Cards'**
  String get islamicCards;

  /// No description provided for @cards8.
  ///
  /// In en, this message translates to:
  /// **'8 Cards'**
  String get cards8;

  /// No description provided for @eidCards.
  ///
  /// In en, this message translates to:
  /// **'Eid\nCards'**
  String get eidCards;

  /// No description provided for @jummaMubarak.
  ///
  /// In en, this message translates to:
  /// **'Jumma\nMubarak'**
  String get jummaMubarak;

  /// No description provided for @ramadanKareem.
  ///
  /// In en, this message translates to:
  /// **'Ramadan\nKareem'**
  String get ramadanKareem;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Your Favorite Cards'**
  String get searchHint;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get navCards;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get navFavorite;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @noCardsHere.
  ///
  /// In en, this message translates to:
  /// **'No Cards Here'**
  String get noCardsHere;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @newCardsDropped.
  ///
  /// In en, this message translates to:
  /// **'New Cards Just Dropped'**
  String get newCardsDropped;

  /// No description provided for @newCardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Check out our latest collection of birthday and celebration cards - freshly added just for you.'**
  String get newCardsDesc;

  /// No description provided for @time3m.
  ///
  /// In en, this message translates to:
  /// **'3m'**
  String get time3m;

  /// No description provided for @time3h.
  ///
  /// In en, this message translates to:
  /// **'3h'**
  String get time3h;

  /// No description provided for @time5h.
  ///
  /// In en, this message translates to:
  /// **'5h'**
  String get time5h;

  /// No description provided for @time1d.
  ///
  /// In en, this message translates to:
  /// **'1d'**
  String get time1d;

  /// No description provided for @time3d.
  ///
  /// In en, this message translates to:
  /// **'3d'**
  String get time3d;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @apr7_2026.
  ///
  /// In en, this message translates to:
  /// **'Apr 7, 2026'**
  String get apr7_2026;

  /// No description provided for @limitedTimeOffer.
  ///
  /// In en, this message translates to:
  /// **'Limited Time Offer'**
  String get limitedTimeOffer;

  /// No description provided for @limitedTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Get 20% off on all premium cards this weekend only. Use code WEEKEND20 at checkout.'**
  String get limitedTimeDesc;

  /// No description provided for @freeCardReady.
  ///
  /// In en, this message translates to:
  /// **'Your Free Card is Ready!'**
  String get freeCardReady;

  /// No description provided for @freeCardDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned a free card from your loyalty rewards. Head to the Vault to redeem it.'**
  String get freeCardDesc;

  /// No description provided for @happySiblingsDay.
  ///
  /// In en, this message translates to:
  /// **'Happy Siblings Day!'**
  String get happySiblingsDay;

  /// No description provided for @happySiblingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to send a card to your sibling today. We have a great collection just for this occasion.'**
  String get happySiblingsDesc;

  /// No description provided for @mothersDayComing.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Day is Coming Up'**
  String get mothersDayComing;

  /// No description provided for @mothersDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Day is just 3 days away. Schedule a card now so it arrives right on time.'**
  String get mothersDayDesc;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profileInitial.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get profileInitial;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Samama Hussain'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'samamahussain23@gmail.com'**
  String get profileEmail;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
