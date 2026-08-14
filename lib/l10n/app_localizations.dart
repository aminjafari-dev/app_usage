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
  /// **'App Usage'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s usage'**
  String get homeTitle;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @unsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not supported'**
  String get unsupportedTitle;

  /// No description provided for @unsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Live app usage tracking with a floating counter is only available on Android.'**
  String get unsupportedMessage;

  /// No description provided for @usagePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage access'**
  String get usagePermissionTitle;

  /// No description provided for @usagePermissionBody.
  ///
  /// In en, this message translates to:
  /// **'To help you find balance, we gently monitor your app usage. No harsh locks — just awareness on this device.'**
  String get usagePermissionBody;

  /// No description provided for @overlayPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Display over other apps'**
  String get overlayPermissionTitle;

  /// No description provided for @overlayPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'A small floating counter stays with you so you always know how much time you\'ve spent today.'**
  String get overlayPermissionBody;

  /// No description provided for @batteryPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted battery'**
  String get batteryPermissionTitle;

  /// No description provided for @batteryPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the counter alive after you clear Recents. Without this, Android may stop tracking to save battery.'**
  String get batteryPermissionBody;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
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
  /// **'Granted'**
  String get permissionGranted;

  /// No description provided for @permissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get permissionMissing;

  /// No description provided for @permissionStep.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String permissionStep(int current, int total);

  /// No description provided for @continueNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueNext;

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Continue — counter starts automatically'**
  String get continueToHome;

  /// No description provided for @learnMorePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Learn more about privacy'**
  String get learnMorePrivacy;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Enable live counter'**
  String get startTracking;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Disable live counter'**
  String get stopTracking;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'Live counter is on — open any app to see it at the top'**
  String get trackingActive;

  /// No description provided for @trackingInactive.
  ///
  /// In en, this message translates to:
  /// **'Live counter is off'**
  String get trackingInactive;

  /// No description provided for @noUsageYet.
  ///
  /// In en, this message translates to:
  /// **'No usage yet...'**
  String get noUsageYet;

  /// No description provided for @noUsageYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open apps on your phone to start tracking today\'s screen time.'**
  String get noUsageYetSubtitle;

  /// No description provided for @currentApp.
  ///
  /// In en, this message translates to:
  /// **'Current app'**
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
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @permissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Usage access, overlay, and unrestricted battery are required for the live counter.'**
  String get permissionsRequired;

  /// No description provided for @permissionsRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Grant the required access so the live counter can float over other apps.'**
  String get permissionsRequiredHint;

  /// No description provided for @todaySectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todaySectionHeader;

  /// No description provided for @totalUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Total usage today'**
  String get totalUsageLabel;

  /// No description provided for @trackingSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Live counter'**
  String get trackingSectionHeader;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
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
  /// **'Allow the following so the floating counter can work like a Telegram overlay badge.'**
  String get permissionsIntro;

  /// No description provided for @footerHintPermissions.
  ///
  /// In en, this message translates to:
  /// **'Only this device can read usage stats. Nothing is uploaded.'**
  String get footerHintPermissions;

  /// No description provided for @secondsFormat.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String secondsFormat(String time);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsTrackerSection.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get settingsTrackerSection;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @badgeAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Badge Appearance'**
  String get badgeAppearanceTitle;

  /// No description provided for @badgeAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Size & Opacity'**
  String get badgeAppearanceSubtitle;

  /// No description provided for @customizeBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Badge'**
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
  /// **'Save Changes'**
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

  /// No description provided for @tabComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section is coming soon.'**
  String get tabComingSoon;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile and account details.'**
  String get profileSubtitle;

  /// No description provided for @timerPickAppHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an app to set a daily usage limit.'**
  String get timerPickAppHint;

  /// No description provided for @timerSetDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set daily usage limit'**
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
  /// **'Remind me when limit reached'**
  String get timerNotifyWhenReached;

  /// No description provided for @timerSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set Timer'**
  String get timerSetButton;

  /// No description provided for @timerSaved.
  ///
  /// In en, this message translates to:
  /// **'Daily limit saved.'**
  String get timerSaved;

  /// No description provided for @timerInvalidLimit.
  ///
  /// In en, this message translates to:
  /// **'Choose a time greater than zero.'**
  String get timerInvalidLimit;

  /// No description provided for @timerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No apps yet'**
  String get timerEmptyTitle;

  /// No description provided for @timerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use some apps today, then come back to set a limit.'**
  String get timerEmptySubtitle;

  /// No description provided for @timerLimitSummary.
  ///
  /// In en, this message translates to:
  /// **'Limit {hours}h {minutes}m'**
  String timerLimitSummary(int hours, int minutes);

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Time check'**
  String get coachTitle;

  /// No description provided for @coachOverLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re {minutes} min over your daily limit for {app}.'**
  String coachOverLimitSubtitle(String app, int minutes);

  /// No description provided for @coachMessageBoss.
  ///
  /// In en, this message translates to:
  /// **'You\'re the boss of the phone — not the other way around.'**
  String get coachMessageBoss;

  /// No description provided for @coachMessageGoal.
  ///
  /// In en, this message translates to:
  /// **'Follow your goal. This app can wait.'**
  String get coachMessageGoal;

  /// No description provided for @coachMessageAppsChange.
  ///
  /// In en, this message translates to:
  /// **'Don\'t let an app rewrite your day.'**
  String get coachMessageAppsChange;

  /// No description provided for @coachMessagePause.
  ///
  /// In en, this message translates to:
  /// **'One breath. Then decide if you still want to stay.'**
  String get coachMessagePause;

  /// No description provided for @coachMessageChoice.
  ///
  /// In en, this message translates to:
  /// **'You chose a limit for a reason. Honor it.'**
  String get coachMessageChoice;

  /// No description provided for @coachMessageProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect the time you saved for what matters.'**
  String get coachMessageProtect;

  /// No description provided for @coachPauseButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ll pause'**
  String get coachPauseButton;

  /// No description provided for @coachSnoozeButton.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 more minute} other{{minutes} more minutes}}'**
  String coachSnoozeButton(int minutes);

  /// No description provided for @coachMuteToday.
  ///
  /// In en, this message translates to:
  /// **'Mute reminders for this app today'**
  String get coachMuteToday;

  /// No description provided for @coachSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit reminders'**
  String get coachSettingsTitle;

  /// No description provided for @coachSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle check-ins when you go past a daily app limit.'**
  String get coachSettingsSubtitle;

  /// No description provided for @coachSettingsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Show limit reminders'**
  String get coachSettingsEnabled;

  /// No description provided for @coachSettingsEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Alert on the badge when a timed app goes over its limit'**
  String get coachSettingsEnabledHint;

  /// No description provided for @coachSettingsSnoozeLabel.
  ///
  /// In en, this message translates to:
  /// **'Snooze interval'**
  String get coachSettingsSnoozeLabel;

  /// No description provided for @coachSettingsSnoozeHint.
  ///
  /// In en, this message translates to:
  /// **'How long to wait after “more minutes”.'**
  String get coachSettingsSnoozeHint;

  /// No description provided for @coachSettingsMaxNudgesLabel.
  ///
  /// In en, this message translates to:
  /// **'Max reminders per app / day'**
  String get coachSettingsMaxNudgesLabel;

  /// No description provided for @coachSettingsMaxNudgesHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps reminders helpful instead of noisy.'**
  String get coachSettingsMaxNudgesHint;

  /// No description provided for @coachSettingsAllowMute.
  ///
  /// In en, this message translates to:
  /// **'Allow “mute today”'**
  String get coachSettingsAllowMute;

  /// No description provided for @coachSettingsAllowMuteHint.
  ///
  /// In en, this message translates to:
  /// **'Show a button to silence one app until tomorrow'**
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
  /// **'Reminders turned off'**
  String get coachSettingsOff;

  /// No description provided for @coachAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Dialog Appearance'**
  String get coachAppearanceTitle;

  /// No description provided for @coachAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preview the over-limit quote'**
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
  /// **'Daily limit reached'**
  String get coachLimitAlert;
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
