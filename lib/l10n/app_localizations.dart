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
  /// **'Welcome!'**
  String get welcomeBack;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Someone\'s smile could start with a card from you today.'**
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
  /// **'No favorites yet.'**
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

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @emptyOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get emptyOrderHistory;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @legalAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Legal & Privacy'**
  String get legalAndPrivacy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profileInitial.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get profileInitial;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get profileName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'samamahussain23@gmail.com'**
  String get profileEmail;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Logout confirmation'**
  String get logoutConfirmation;

  /// No description provided for @loginFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailedTitle;

  /// No description provided for @loginFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in. Please check your details and try again.'**
  String get loginFailedMessage;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @loginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to unlock your settings.'**
  String get loginPrompt;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginAction;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

  /// No description provided for @addYourEventsHere.
  ///
  /// In en, this message translates to:
  /// **'Add your\nevents here'**
  String get addYourEventsHere;

  /// No description provided for @upcomingOccasions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Occasions'**
  String get upcomingOccasions;

  /// No description provided for @noEventsHere.
  ///
  /// In en, this message translates to:
  /// **'No upcoming events'**
  String get noEventsHere;

  /// No description provided for @addBtn.
  ///
  /// In en, this message translates to:
  /// **'+ ADD'**
  String get addBtn;

  /// No description provided for @addReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminderTitle;

  /// No description provided for @addReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add reminders for your favorite events and occasions.'**
  String get addReminderSubtitle;

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title here.'**
  String get eventTitleHint;

  /// No description provided for @eventReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get eventReminderLabel;

  /// No description provided for @eventReminderHint.
  ///
  /// In en, this message translates to:
  /// **'When do you wanna get a reminder?'**
  String get eventReminderHint;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDateLabel;

  /// No description provided for @eventDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get eventDateHint;

  /// No description provided for @eventDateSubtext.
  ///
  /// In en, this message translates to:
  /// **'Go with your best guess.'**
  String get eventDateSubtext;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminder;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. This Privacy Policy explains how Daimond App collects, uses, and protects your personal information when you use our mobile application and related services.\n\n1. Information We Collect\nWe collect information you provide directly, such as your name, email address, password, and profile details when you create an account. We also collect the content you create, including custom text and uploaded images for e-cards, as well as data regarding your device, app usage, and preferences.\n\n2. How We Use Your Information\nYour information is used to provide, maintain, and improve our services. This includes personalizing your experience, processing your e-card customizations, sending event reminders, managing your account, and communicating with you regarding updates, security alerts, and support.\n\n3. Data Storage and Security\nWe implement industry-standard security measures to protect your data. Your information is securely stored using Supabase, which utilizes advanced encryption and Row Level Security to ensure your data is isolated and protected from unauthorized access. However, no electronic transmission or storage is 100% secure.\n\n4. Sharing Your Information\nWe do not sell your personal information. We may share your data with trusted third-party service providers strictly to facilitate our services. We may also disclose information if required by law or to protect the rights and safety of our users.\n\n5. Your Privacy Rights\nYou have the right to access, update, or delete your personal information at any time through the app settings. You may also opt-out of promotional communications via your Notification Settings.\n\n6. Changes to This Policy\nWe may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy within the app. Your continued use of the app after such modifications constitutes your acknowledgment of the updated policy.\n\n7. Contact Us\nIf you have any questions or concerns about this Privacy Policy or our data practices, please contact us at support.ominilogics@gmail.com.'**
  String get privacyPolicyContent;

  /// No description provided for @termsAndConditionsContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Daimond App. By accessing or using our mobile application, you agree to be bound by these Terms and Conditions. Please read them carefully before using our services.\n\n1. Acceptance of Terms\nBy creating an account or using the app, you agree to these Terms. If you do not agree to all the terms and conditions, you may not access or use the service.\n\n2. User Accounts\nYou are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must notify us immediately of any unauthorized use or security breaches.\n\n3. User-Generated Content\nOur service allows you to customize e-cards with your own text, images, and other content. You retain ownership of your content, but you grant us a license to use, store, and display it to provide the service. You agree not to upload or share content that is illegal, abusive, offensive, defamatory, or infringes on the intellectual property rights of others.\n\n4. Intellectual Property\nThe Daimond App, including its original content, features, designs, and card templates, are owned by us and are protected by international copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, or create derivative works without explicit permission.\n\n5. Subscriptions and Payments\nCertain features or premium cards may require payment or a subscription. All fees are clearly stated within the app. By choosing a paid service, you agree to our billing terms. Subscriptions auto-renew unless canceled prior to the renewal date.\n\n6. Limitation of Liability\nTo the maximum extent permitted by law, Daimond App and its affiliates shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.\n\n7. Termination\nWe reserve the right to suspend or terminate your account at our sole discretion, without prior notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties.\n\n8. Changes to Terms\nWe reserve the right to modify or replace these Terms at any time. Material changes will be communicated through the app. Continued use of the app constitutes acceptance of the new Terms.\n\n9. Governing Law\nThese Terms shall be governed and construed in accordance with the laws of your jurisdiction, without regard to its conflict of law provisions.\n\n10. Contact Information\nFor any questions regarding these Terms, please contact our support team.'**
  String get termsAndConditionsContent;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @islamicEvents.
  ///
  /// In en, this message translates to:
  /// **'Islamic Events'**
  String get islamicEvents;

  /// No description provided for @newCardAlerts.
  ///
  /// In en, this message translates to:
  /// **'New Card Alerts'**
  String get newCardAlerts;

  /// No description provided for @eventReminders.
  ///
  /// In en, this message translates to:
  /// **'Event Reminders'**
  String get eventReminders;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone once confirmed.'**
  String get deleteAccountMessage;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account? You will need to enter your credentials again to access your saved cards and preferences.'**
  String get logoutMessage;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get subscriptionHeading;

  /// No description provided for @subscriptionSubheading.
  ///
  /// In en, this message translates to:
  /// **'Never miss a special occasion. Choose a plan below to start sending beautifully designed cards directly to your loved ones every month.'**
  String get subscriptionSubheading;

  /// No description provided for @subscriptionGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. Secure payment.'**
  String get subscriptionGuarantee;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsOfService;

  /// No description provided for @subscriptionBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s included in every plan:'**
  String get subscriptionBenefitsTitle;

  /// No description provided for @subscriptionBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to all standard templates'**
  String get subscriptionBenefit1;

  /// No description provided for @subscriptionBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Send cards instantly to anyone, anywhere'**
  String get subscriptionBenefit2;

  /// No description provided for @subscriptionBenefit3.
  ///
  /// In en, this message translates to:
  /// **'No hidden fees, cancel anytime'**
  String get subscriptionBenefit3;

  /// No description provided for @plan1Title.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get plan1Title;

  /// No description provided for @plan1Desc.
  ///
  /// In en, this message translates to:
  /// **'Perfect for sending occasional cards to your loved ones.'**
  String get plan1Desc;

  /// No description provided for @plan1Cards.
  ///
  /// In en, this message translates to:
  /// **'5 Cards'**
  String get plan1Cards;

  /// No description provided for @plan1Price.
  ///
  /// In en, this message translates to:
  /// **'\$4.99 / mo'**
  String get plan1Price;

  /// No description provided for @plan2Title.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get plan2Title;

  /// No description provided for @plan2Desc.
  ///
  /// In en, this message translates to:
  /// **'For those who want to celebrate every moment in style.'**
  String get plan2Desc;

  /// No description provided for @plan2Cards.
  ///
  /// In en, this message translates to:
  /// **'10 Cards'**
  String get plan2Cards;

  /// No description provided for @plan2Price.
  ///
  /// In en, this message translates to:
  /// **'\$8.99 / mo'**
  String get plan2Price;

  /// No description provided for @subscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeButton;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign up successful! You can now log in.'**
  String get signUpSuccess;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email!'**
  String get forgotPasswordSuccess;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logout successful!'**
  String get logoutSuccess;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @myDrafts.
  ///
  /// In en, this message translates to:
  /// **'My Drafts'**
  String get myDrafts;

  /// No description provided for @noDraftsSavedYet.
  ///
  /// In en, this message translates to:
  /// **'No drafts saved yet.'**
  String get noDraftsSavedYet;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard your edits? Any unsaved changes you\'ve made to this card will be permanently lost.'**
  String get discardChangesDesc;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @customizeCard.
  ///
  /// In en, this message translates to:
  /// **'Customize Card'**
  String get customizeCard;

  /// No description provided for @editCoverText.
  ///
  /// In en, this message translates to:
  /// **'Edit Cover Text'**
  String get editCoverText;

  /// No description provided for @editInsideMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit Inside Message'**
  String get editInsideMessage;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @savedToMyDrafts.
  ///
  /// In en, this message translates to:
  /// **'Saved to My Drafts'**
  String get savedToMyDrafts;

  /// No description provided for @addRecipient.
  ///
  /// In en, this message translates to:
  /// **'Add Recipient'**
  String get addRecipient;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @fromHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name here.'**
  String get fromHint;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @toHint.
  ///
  /// In en, this message translates to:
  /// **'Enter recipient\'s name here.'**
  String get toHint;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get continueText;

  /// No description provided for @draftPrefix.
  ///
  /// In en, this message translates to:
  /// **'Draft: '**
  String get draftPrefix;

  /// No description provided for @coverPrefix.
  ///
  /// In en, this message translates to:
  /// **'Cover: '**
  String get coverPrefix;

  /// No description provided for @insidePrefix.
  ///
  /// In en, this message translates to:
  /// **'Inside: '**
  String get insidePrefix;

  /// No description provided for @enterDraftName.
  ///
  /// In en, this message translates to:
  /// **'Enter draft name...'**
  String get enterDraftName;

  /// No description provided for @fieldsCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cover and inside text cannot be empty.'**
  String get fieldsCannotBeEmpty;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get pleaseEnterName;

  /// No description provided for @nameExceeds15Letters.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 15 letters.'**
  String get nameExceeds15Letters;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'Select Date (Optional)'**
  String get dateOfBirthHint;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulations;

  /// No description provided for @mothersDay.
  ///
  /// In en, this message translates to:
  /// **'Mother\'s Day'**
  String get mothersDay;

  /// No description provided for @fathersDay.
  ///
  /// In en, this message translates to:
  /// **'Father\'s Day'**
  String get fathersDay;

  /// No description provided for @belatedBirthday.
  ///
  /// In en, this message translates to:
  /// **'Belated Birthday'**
  String get belatedBirthday;

  /// No description provided for @friendship.
  ///
  /// In en, this message translates to:
  /// **'Friendship'**
  String get friendship;

  /// No description provided for @sympathy.
  ///
  /// In en, this message translates to:
  /// **'Sympathy'**
  String get sympathy;

  /// No description provided for @missingYou.
  ///
  /// In en, this message translates to:
  /// **'Missing You'**
  String get missingYou;

  /// No description provided for @troubledRelationship.
  ///
  /// In en, this message translates to:
  /// **'Troubled Relationship'**
  String get troubledRelationship;

  /// No description provided for @advice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get advice;

  /// No description provided for @wedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get wedding;

  /// No description provided for @goodLuck.
  ///
  /// In en, this message translates to:
  /// **'Good Luck'**
  String get goodLuck;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorOccurred;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccessful;

  /// No description provided for @restoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get restoreSuccessful;

  /// No description provided for @storeNotReady.
  ///
  /// In en, this message translates to:
  /// **'Store is not ready yet. Please try again later.'**
  String get storeNotReady;

  /// No description provided for @manageSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscriptions'**
  String get manageSubscriptions;

  /// No description provided for @customizedCardFallback.
  ///
  /// In en, this message translates to:
  /// **'Customized Card'**
  String get customizedCardFallback;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @pleaseEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message for the card.'**
  String get pleaseEnterMessage;

  /// No description provided for @pleaseFillRecipientFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all recipient fields.'**
  String get pleaseFillRecipientFields;

  /// No description provided for @singleCardNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Single card product is not available right now.'**
  String get singleCardNotAvailable;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @pleaseFillMessageFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill out all message fields.'**
  String get pleaseFillMessageFields;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetails;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @defaultCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Loving you has been one of life\'s greatest gifts. No matter where life takes us, my heart will always find its way back to you.'**
  String get defaultCardDescription;
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
