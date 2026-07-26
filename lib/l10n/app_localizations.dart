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
  /// **'Allow this app to see which apps you use so we can count today\'s time.'**
  String get usagePermissionBody;

  /// No description provided for @overlayPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Display over other apps'**
  String get overlayPermissionTitle;

  /// No description provided for @overlayPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow a small glassy counter to float over other apps.'**
  String get overlayPermissionBody;

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

  /// No description provided for @continueToHome.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToHome;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start live counter'**
  String get startTracking;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop live counter'**
  String get stopTracking;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'Live counter is running'**
  String get trackingActive;

  /// No description provided for @trackingInactive.
  ///
  /// In en, this message translates to:
  /// **'Live counter is off'**
  String get trackingInactive;

  /// No description provided for @noUsageYet.
  ///
  /// In en, this message translates to:
  /// **'No app usage recorded for today yet.'**
  String get noUsageYet;

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
  /// **'Both permissions are required to start tracking.'**
  String get permissionsRequired;

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
