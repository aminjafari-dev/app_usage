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
