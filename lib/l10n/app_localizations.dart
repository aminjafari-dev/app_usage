import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Shirin\'s Focus'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day, my love'**
  String get homeTitle;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'A few little permissions, Shirin jan'**
  String get permissionsTitle;

  /// No description provided for @permissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Just so I can look after your time, azizam'**
  String get permissionsSubtitle;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Okay, love'**
  String get permissionAllow;

  /// No description provided for @unsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Aw… not this phone, joonam'**
  String get unsupportedTitle;

  /// No description provided for @unsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'The live counter only works on Android — like a little gift meant for your phone.'**
  String get unsupportedMessage;

  /// No description provided for @usagePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage access'**
  String get usagePermissionTitle;

  /// No description provided for @usagePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Azizam, I just want to gently see how your day goes — no harsh locks, only love and awareness on this phone, made for you.'**
  String get usagePermissionBody;

  /// No description provided for @overlayPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Display over other apps'**
  String get overlayPermissionTitle;

  /// No description provided for @overlayPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'A soft little badge stays beside you, ghashangam, so you always know how your time is going.'**
  String get overlayPermissionBody;

  /// No description provided for @batteryPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted battery'**
  String get batteryPermissionTitle;

  /// No description provided for @batteryPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Joonam, allow this so your counter doesn’t quietly disappear after you clear Recents — I want it to stay with you.'**
  String get batteryPermissionBody;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Let’s go, azizam'**
  String get grantAccess;

  /// No description provided for @grantUsageAccess.
  ///
  /// In en, this message translates to:
  /// **'Open usage access'**
  String get grantUsageAccess;

  /// No description provided for @grantOverlayAccess.
  ///
  /// In en, this message translates to:
  /// **'Open overlay settings'**
  String get grantOverlayAccess;

  /// No description provided for @grantBatteryUnrestricted.
  ///
  /// In en, this message translates to:
  /// **'Allow unrestricted battery'**
  String get grantBatteryUnrestricted;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Well done, love 💕'**
  String get permissionGranted;

  /// No description provided for @permissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Still needed, ghashangam'**
  String get permissionMissing;

  /// No description provided for @permissionStep.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String permissionStep(int current, int total);

  /// No description provided for @continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue, azizam'**
  String get continueNext;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Let’s go home — your counter turns on with love'**
  String get continueToHome;

  /// No description provided for @learnMorePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Learn more about your privacy'**
  String get learnMorePrivacy;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Turn the counter on, ghashangam'**
  String get startTracking;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Turn it off for now'**
  String get stopTracking;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'Counter is on, aziz delam — open any app and you’ll see it at the top'**
  String get trackingActive;

  /// No description provided for @trackingInactive.
  ///
  /// In en, this message translates to:
  /// **'Counter is off, joonam'**
  String get trackingInactive;

  /// No description provided for @noUsageYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet, golam…'**
  String get noUsageYet;

  /// No description provided for @noUsageYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open some apps so I can see how your day went, Shirin jan.'**
  String get noUsageYetSubtitle;

  /// No description provided for @currentApp.
  ///
  /// In en, this message translates to:
  /// **'You’re here now'**
  String get currentApp;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get switchLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePersian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get languagePersian;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh, azizam'**
  String get refresh;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong azizam — try again, love.'**
  String get errorGeneric;

  /// No description provided for @permissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Azizam, the live counter needs usage, overlay, and unrestricted battery.'**
  String get permissionsRequired;

  /// No description provided for @permissionsRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Grant access so this little helper can stay beside you with love.'**
  String get permissionsRequiredHint;

  /// No description provided for @todaySectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Your today'**
  String get todaySectionHeader;

  /// No description provided for @totalUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your total time today'**
  String get totalUsageLabel;

  /// No description provided for @trackingSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Loving counter'**
  String get trackingSectionHeader;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Watching over you'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get statusOffline;

  /// No description provided for @quickRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get quickRefresh;

  /// No description provided for @quickLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get quickLanguage;

  /// No description provided for @quickSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get quickSettings;

  /// No description provided for @quickPermissions.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get quickPermissions;

  /// No description provided for @openPermissions.
  ///
  /// In en, this message translates to:
  /// **'Open permissions'**
  String get openPermissions;

  /// No description provided for @appsTracked.
  ///
  /// In en, this message translates to:
  /// **'{count} apps'**
  String appsTracked(int count);

  /// No description provided for @permissionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Allow these, ghashangam, so the floating badge can stay on your screen like a soft little kiss.'**
  String get permissionsIntro;

  /// No description provided for @footerHintPermissions.
  ///
  /// In en, this message translates to:
  /// **'Don’t worry azizam — only this phone reads your usage. Nothing goes anywhere.'**
  String get footerHintPermissions;

  /// No description provided for @secondsFormat.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String secondsFormat(String time);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Your preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsTrackerSection.
  ///
  /// In en, this message translates to:
  /// **'Looking after your time'**
  String get settingsTrackerSection;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Soft light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Calm night'**
  String get themeDark;

  /// No description provided for @badgeAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Little badge look'**
  String get badgeAppearanceTitle;

  /// No description provided for @badgeAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Size & opacity — however you like'**
  String get badgeAppearanceSubtitle;

  /// No description provided for @customizeBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Make the badge pretty'**
  String get customizeBadgeTitle;

  /// No description provided for @badgeSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'SIZE'**
  String get badgeSizeLabel;

  /// No description provided for @badgeOpacityLabel.
  ///
  /// In en, this message translates to:
  /// **'OPACITY'**
  String get badgeOpacityLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save, azizam'**
  String get saveChanges;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to leave, ghashangam'**
  String get pressBackAgainToExit;

  /// No description provided for @tabComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This part is coming soon — wait for me, azizam.'**
  String get tabComingSoon;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Shirin joonam'**
  String get profileName;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Made with all the love in the world — only for you, eshgham.'**
  String get profileSubtitle;

  /// No description provided for @profileSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get profileSyncTitle;

  /// No description provided for @profileSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'User id: {userId}'**
  String profileSyncSubtitle(String userId);

  /// No description provided for @profileSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync to Drive now'**
  String get profileSyncNow;

  /// No description provided for @profileSyncOk.
  ///
  /// In en, this message translates to:
  /// **'Synced, azizam 💕'**
  String get profileSyncOk;

  /// No description provided for @profileSyncFail.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t sync yet — will retry later'**
  String get profileSyncFail;

  /// No description provided for @timerPickAppHint.
  ///
  /// In en, this message translates to:
  /// **'Pick an app so I can set a daily limit or lock it for you, aziz delam.'**
  String get timerPickAppHint;

  /// No description provided for @timerSetDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set your daily limit'**
  String get timerSetDailyLimit;

  /// No description provided for @timerHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get timerHoursLabel;

  /// No description provided for @timerMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get timerMinutesLabel;

  /// No description provided for @timerNotifyWhenReached.
  ///
  /// In en, this message translates to:
  /// **'Remind me when I reach the limit, joonam'**
  String get timerNotifyWhenReached;

  /// No description provided for @timerSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set it, ghashangam'**
  String get timerSetButton;

  /// No description provided for @timerSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved — I’m watching over your time, azizam.'**
  String get timerSaved;

  /// No description provided for @timerInvalidLimit.
  ///
  /// In en, this message translates to:
  /// **'Choose more than zero, golam.'**
  String get timerInvalidLimit;

  /// No description provided for @timerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No apps yet, Shirin jan'**
  String get timerEmptyTitle;

  /// No description provided for @timerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use some apps today, then come back and we’ll set it together.'**
  String get timerEmptySubtitle;

  /// No description provided for @timerLimitSummary.
  ///
  /// In en, this message translates to:
  /// **'Limit {hours}h {minutes}m'**
  String timerLimitSummary(int hours, int minutes);

  /// No description provided for @timerBlockWhenOpened.
  ///
  /// In en, this message translates to:
  /// **'Lock this app when opened'**
  String get timerBlockWhenOpened;

  /// No description provided for @timerBlockWhenOpenedHint.
  ///
  /// In en, this message translates to:
  /// **'A soft full-screen lock appears to protect your time, azizam.'**
  String get timerBlockWhenOpenedHint;

  /// No description provided for @timerBlockLockedHint.
  ///
  /// In en, this message translates to:
  /// **'This app is always locked and can’t be changed.'**
  String get timerBlockLockedHint;

  /// No description provided for @timerBlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked with love'**
  String get timerBlockedLabel;

  /// No description provided for @timerAlwaysBlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Always locked'**
  String get timerAlwaysBlockedLabel;

  /// No description provided for @timerLimitAndBlockedSummary.
  ///
  /// In en, this message translates to:
  /// **'Limit {hours}h {minutes}m · Locked'**
  String timerLimitAndBlockedSummary(int hours, int minutes);

  /// No description provided for @timerBlockSaved.
  ///
  /// In en, this message translates to:
  /// **'Okay azizam, lock updated.'**
  String get timerBlockSaved;

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Wait a second, ghashangam'**
  String get blockTitle;

  /// No description provided for @blockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{appName} is locked right now. Leave so your day stays calm, azizam.'**
  String blockSubtitle(String appName);

  /// No description provided for @blockLeaveButton.
  ///
  /// In en, this message translates to:
  /// **'Okay, I’m leaving'**
  String get blockLeaveButton;

  /// No description provided for @blockHint.
  ///
  /// In en, this message translates to:
  /// **'You asked for this lock to protect your time — it stays until you leave, joonam.'**
  String get blockHint;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Hi eshgham'**
  String get coachTitle;

  /// No description provided for @coachOverLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Aziz delam, you’re {minutes} min past your daily limit.'**
  String coachOverLimitSubtitle(int minutes);

  /// No description provided for @coachMessageBoss.
  ///
  /// In en, this message translates to:
  /// **'Shirin joonam, you’re the boss of this phone — not the other way around, azizam.'**
  String get coachMessageBoss;

  /// No description provided for @coachMessageGoal.
  ///
  /// In en, this message translates to:
  /// **'Follow your goal, ghashangam. This app can wait.'**
  String get coachMessageGoal;

  /// No description provided for @coachMessageAppsChange.
  ///
  /// In en, this message translates to:
  /// **'Don’t let an app ruin your beautiful day, aziz delam.'**
  String get coachMessageAppsChange;

  /// No description provided for @coachMessagePause.
  ///
  /// In en, this message translates to:
  /// **'One soft breath, rooham. Then see if you still want to stay.'**
  String get coachMessagePause;

  /// No description provided for @coachMessageChoice.
  ///
  /// In en, this message translates to:
  /// **'You set this limit for yourself. Honor it, eshgham.'**
  String get coachMessageChoice;

  /// No description provided for @coachMessageProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect the time you saved for what matters, nazanin.'**
  String get coachMessageProtect;

  /// No description provided for @coachMessageProtectPeace.
  ///
  /// In en, this message translates to:
  /// **'Your peace is gold, Shirin jan — keep it.'**
  String get coachMessageProtectPeace;

  /// No description provided for @coachMessageProtectEnergy.
  ///
  /// In en, this message translates to:
  /// **'Your energy is yours, golam — don’t waste it.'**
  String get coachMessageProtectEnergy;

  /// No description provided for @coachMessageTrustProcess.
  ///
  /// In en, this message translates to:
  /// **'Trust yourself, azizam. You’re doing so beautifully.'**
  String get coachMessageTrustProcess;

  /// No description provided for @coachMessageProgressOverPerfection.
  ///
  /// In en, this message translates to:
  /// **'You don’t need to be perfect, joonam — just keep going.'**
  String get coachMessageProgressOverPerfection;

  /// No description provided for @coachMessageComparisonThief.
  ///
  /// In en, this message translates to:
  /// **'Don’t compare yourself to anyone, ghashangam — you’re one of a kind.'**
  String get coachMessageComparisonThief;

  /// No description provided for @coachMessageDoneBetterPerfect.
  ///
  /// In en, this message translates to:
  /// **'Done is better than perfect, azizam.'**
  String get coachMessageDoneBetterPerfect;

  /// No description provided for @coachMessageDisciplineFreedom.
  ///
  /// In en, this message translates to:
  /// **'A soft bit of discipline means more freedom for you, eshgham.'**
  String get coachMessageDisciplineFreedom;

  /// No description provided for @coachMessageStayHungry.
  ///
  /// In en, this message translates to:
  /// **'Stay curious, stay kind to yourself, rooham.'**
  String get coachMessageStayHungry;

  /// No description provided for @coachMessageBeSoGood.
  ///
  /// In en, this message translates to:
  /// **'You’re already so good they can’t ignore you, Shirin joon.'**
  String get coachMessageBeSoGood;

  /// No description provided for @coachMessageImpossibleUntilDone.
  ///
  /// In en, this message translates to:
  /// **'It feels hard until you do it, ghashangam — and you can.'**
  String get coachMessageImpossibleUntilDone;

  /// No description provided for @coachMessageBelieveHalfway.
  ///
  /// In en, this message translates to:
  /// **'Believe you can, aziz delam — you’re already halfway there.'**
  String get coachMessageBelieveHalfway;

  /// No description provided for @coachMessageGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'The secret? Just starting, golam. Start, love.'**
  String get coachMessageGettingStarted;

  /// No description provided for @coachMessageShotsYouDontTake.
  ///
  /// In en, this message translates to:
  /// **'What you never try, you lose — be brave, joonam.'**
  String get coachMessageShotsYouDontTake;

  /// No description provided for @coachMessageFallSeven.
  ///
  /// In en, this message translates to:
  /// **'Fall seven times, stand up eight — I’m right here, eshgham.'**
  String get coachMessageFallSeven;

  /// No description provided for @coachMessageStartWhereYouAre.
  ///
  /// In en, this message translates to:
  /// **'Start right where you are, nazanin. With what you have.'**
  String get coachMessageStartWhereYouAre;

  /// No description provided for @coachMessageRepeatedlyDo.
  ///
  /// In en, this message translates to:
  /// **'We become our little habits — so choose the pretty ones, azizam.'**
  String get coachMessageRepeatedlyDo;

  /// No description provided for @coachMessageLittleByLittle.
  ///
  /// In en, this message translates to:
  /// **'Little by little, ghashangam — slowly it grows.'**
  String get coachMessageLittleByLittle;

  /// No description provided for @coachMessageProductiveNotBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy isn’t the point — useful is, rooham.'**
  String get coachMessageProductiveNotBusy;

  /// No description provided for @coachMessageHardWorkTalent.
  ///
  /// In en, this message translates to:
  /// **'Your effort is prettier than unused talent, Shirin jan.'**
  String get coachMessageHardWorkTalent;

  /// No description provided for @coachMessageSuccessNotFinal.
  ///
  /// In en, this message translates to:
  /// **'Success isn’t the end, failure isn’t either, azizam.'**
  String get coachMessageSuccessNotFinal;

  /// No description provided for @coachMessageSmallWins.
  ///
  /// In en, this message translates to:
  /// **'Little wins still count with love, ghashangam.'**
  String get coachMessageSmallWins;

  /// No description provided for @coachMessageRestProductive.
  ///
  /// In en, this message translates to:
  /// **'Rest is love too — give yourself a break, joonam.'**
  String get coachMessageRestProductive;

  /// No description provided for @coachMessageDisciplineSelfLove.
  ///
  /// In en, this message translates to:
  /// **'Looking after yourself is self-love — and you deserve that love, aziz delam.'**
  String get coachMessageDisciplineSelfLove;

  /// No description provided for @coachMessageDecisionsDistractions.
  ///
  /// In en, this message translates to:
  /// **'Your sweet decisions matter more than mindless scrolling, eshgham.'**
  String get coachMessageDecisionsDistractions;

  /// No description provided for @coachMessageCameThisFar.
  ///
  /// In en, this message translates to:
  /// **'You didn’t come this far just to stop here — keep going, azizam.'**
  String get coachMessageCameThisFar;

  /// No description provided for @coachMessageMakeItExist.
  ///
  /// In en, this message translates to:
  /// **'Just start first, then make it pretty, golam.'**
  String get coachMessageMakeItExist;

  /// No description provided for @coachMessageWholePoint.
  ///
  /// In en, this message translates to:
  /// **'Remember — you’re the point, not this screen, rooham.'**
  String get coachMessageWholePoint;

  /// No description provided for @coachMessageNextOpponent.
  ///
  /// In en, this message translates to:
  /// **'Your main opponent is you — and you’re winning beautifully, Shirin joon.'**
  String get coachMessageNextOpponent;

  /// No description provided for @coachMessageFearRespect.
  ///
  /// In en, this message translates to:
  /// **'Be strong, be kind — just like you are, nazanin.'**
  String get coachMessageFearRespect;

  /// No description provided for @coachMessageEmptyCup.
  ///
  /// In en, this message translates to:
  /// **'You can’t pour from an empty cup — fill yours first, azizam.'**
  String get coachMessageEmptyCup;

  /// No description provided for @coachMessageFocusControl.
  ///
  /// In en, this message translates to:
  /// **'Focus on what you can hold, ghashangam.'**
  String get coachMessageFocusControl;

  /// No description provided for @coachMessageLessScrolling.
  ///
  /// In en, this message translates to:
  /// **'Less scrolling, more living — especially for you, eshgham.'**
  String get coachMessageLessScrolling;

  /// No description provided for @coachMessageAttentionCurrency.
  ///
  /// In en, this message translates to:
  /// **'Your attention is your most precious gift, joonam — don’t waste it.'**
  String get coachMessageAttentionCurrency;

  /// No description provided for @coachMessageBePresent.
  ///
  /// In en, this message translates to:
  /// **'Be right here, my Shirin — this moment is yours.'**
  String get coachMessageBePresent;

  /// No description provided for @coachMessageOneDay.
  ///
  /// In en, this message translates to:
  /// **'Day by day, soft and with love, aziz delam.'**
  String get coachMessageOneDay;

  /// No description provided for @coachMessageSmallSteps.
  ///
  /// In en, this message translates to:
  /// **'One little step every day, golam — that’s enough.'**
  String get coachMessageSmallSteps;

  /// No description provided for @coachMessageBuiltConsistency.
  ///
  /// In en, this message translates to:
  /// **'You’re built by consistency, not rush, ghashangam.'**
  String get coachMessageBuiltConsistency;

  /// No description provided for @coachMessagePeacePriority.
  ///
  /// In en, this message translates to:
  /// **'Your peace is my priority for you, rooham.'**
  String get coachMessagePeacePriority;

  /// No description provided for @coachMessageDisciplineMotivation.
  ///
  /// In en, this message translates to:
  /// **'When motivation fades, soft discipline helps, azizam.'**
  String get coachMessageDisciplineMotivation;

  /// No description provided for @coachMessageKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going — I’m so proud of you, eshgham.'**
  String get coachMessageKeepGoing;

  /// No description provided for @coachMessageGrowthLooksGood.
  ///
  /// In en, this message translates to:
  /// **'Growth looks so good on you, Shirin joon — prettier every day.'**
  String get coachMessageGrowthLooksGood;

  /// No description provided for @coachMessageShowingUp.
  ///
  /// In en, this message translates to:
  /// **'Show up for yourself — you deserve it, nazanin.'**
  String get coachMessageShowingUp;

  /// No description provided for @coachMessageQuietGrind.
  ///
  /// In en, this message translates to:
  /// **'Quiet soft grind season — you’re strong, joonam.'**
  String get coachMessageQuietGrind;

  /// No description provided for @coachMessageSoftBoundaries.
  ///
  /// In en, this message translates to:
  /// **'Soft life, strong boundaries — well done azizam.'**
  String get coachMessageSoftBoundaries;

  /// No description provided for @coachMessageMainCharacter.
  ///
  /// In en, this message translates to:
  /// **'You’re the main character of this story, ghashangam.'**
  String get coachMessageMainCharacter;

  /// No description provided for @coachMessageHealingNotLinear.
  ///
  /// In en, this message translates to:
  /// **'Healing isn’t a straight line — be gentle with yourself, rooham.'**
  String get coachMessageHealingNotLinear;

  /// No description provided for @coachMessageDoItScared.
  ///
  /// In en, this message translates to:
  /// **'Do it scared — you’re braver than you think, eshgham.'**
  String get coachMessageDoItScared;

  /// No description provided for @coachMessageComfortZones.
  ///
  /// In en, this message translates to:
  /// **'Great things live outside the comfort zone, golam — take one step.'**
  String get coachMessageComfortZones;

  /// No description provided for @coachMessageDreamsDontWork.
  ///
  /// In en, this message translates to:
  /// **'Dreams don’t work unless you do, Shirin jan.'**
  String get coachMessageDreamsDontWork;

  /// No description provided for @coachMessageBestTimeNow.
  ///
  /// In en, this message translates to:
  /// **'Best time? Right now, aziz delam.'**
  String get coachMessageBestTimeNow;

  /// No description provided for @coachMessageBeYourself.
  ///
  /// In en, this message translates to:
  /// **'Be yourself — every other role is taken, ghashangam.'**
  String get coachMessageBeYourself;

  /// No description provided for @coachMessageStayHard.
  ///
  /// In en, this message translates to:
  /// **'Stay soft, stay strong — the way I love you, joonam.'**
  String get coachMessageStayHard;

  /// No description provided for @coachMessageWhoYouBecome.
  ///
  /// In en, this message translates to:
  /// **'It’s not the destination — it’s who you become, rooham.'**
  String get coachMessageWhoYouBecome;

  /// No description provided for @coachMessageSilenceNoise.
  ///
  /// In en, this message translates to:
  /// **'Silence the noise. Listen to your heart, my Shirin.'**
  String get coachMessageSilenceNoise;

  /// No description provided for @coachPauseButton.
  ///
  /// In en, this message translates to:
  /// **'Okay, I’ll pause azizam'**
  String get coachPauseButton;

  /// No description provided for @coachSnoozeButton.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 more minute, joonam} other{{minutes} more minutes, joonam}}'**
  String coachSnoozeButton(int minutes);

  /// No description provided for @coachMuteToday.
  ///
  /// In en, this message translates to:
  /// **'Mute this reminder for today, ghashangam'**
  String get coachMuteToday;

  /// No description provided for @coachSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Soft reminders'**
  String get coachSettingsTitle;

  /// No description provided for @coachSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A loving check-in when you go past a daily limit.'**
  String get coachSettingsSubtitle;

  /// No description provided for @coachSettingsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Keep limit reminders on'**
  String get coachSettingsEnabled;

  /// No description provided for @coachSettingsEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'I’ll nudge you on the badge when an app goes over, azizam'**
  String get coachSettingsEnabledHint;

  /// No description provided for @coachSettingsSnoozeLabel.
  ///
  /// In en, this message translates to:
  /// **'Snooze interval'**
  String get coachSettingsSnoozeLabel;

  /// No description provided for @coachSettingsSnoozeHint.
  ///
  /// In en, this message translates to:
  /// **'How long should I wait after “more minutes”, joonam.'**
  String get coachSettingsSnoozeHint;

  /// No description provided for @coachSettingsMaxNudgesLabel.
  ///
  /// In en, this message translates to:
  /// **'Max reminders per day'**
  String get coachSettingsMaxNudgesLabel;

  /// No description provided for @coachSettingsMaxNudgesHint.
  ///
  /// In en, this message translates to:
  /// **'Keep reminders sweet, not annoying.'**
  String get coachSettingsMaxNudgesHint;

  /// No description provided for @coachSettingsAllowMute.
  ///
  /// In en, this message translates to:
  /// **'Allow “mute today”'**
  String get coachSettingsAllowMute;

  /// No description provided for @coachSettingsAllowMuteHint.
  ///
  /// In en, this message translates to:
  /// **'A button to silence one app until tomorrow'**
  String get coachSettingsAllowMuteHint;

  /// No description provided for @coachSettingsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String coachSettingsMinutes(int minutes);

  /// No description provided for @coachSettingsSummary.
  ///
  /// In en, this message translates to:
  /// **'Snooze {snooze}m · up to {max} / day'**
  String coachSettingsSummary(int snooze, int max);

  /// No description provided for @coachSettingsOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off, azizam'**
  String get coachSettingsOff;

  /// No description provided for @coachAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Dialog look'**
  String get coachAppearanceTitle;

  /// No description provided for @coachAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview the loving messages'**
  String get coachAppearanceSubtitle;

  /// No description provided for @coachAppearancePreviewApp.
  ///
  /// In en, this message translates to:
  /// **'Sample app'**
  String get coachAppearancePreviewApp;

  /// No description provided for @coachQuoteClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get coachQuoteClose;

  /// No description provided for @coachLimitAlert.
  ///
  /// In en, this message translates to:
  /// **'You hit your daily limit, ghashangam'**
  String get coachLimitAlert;

  /// No description provided for @holidaySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shirin joon’s free day'**
  String get holidaySettingsTitle;

  /// No description provided for @holidaySettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On this day every lock opens — guilt-free scrolling, only for you eshgham.'**
  String get holidaySettingsSubtitle;

  /// No description provided for @holidaySettingsSummary.
  ///
  /// In en, this message translates to:
  /// **'{day} · unlock with love'**
  String holidaySettingsSummary(String day);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;
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
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
