// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'App Usage';

  @override
  String get homeTitle => 'Today\'s usage';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get unsupportedTitle => 'Not supported';

  @override
  String get unsupportedMessage =>
      'Live app usage tracking with a floating counter is only available on Android.';

  @override
  String get usagePermissionTitle => 'Usage access';

  @override
  String get usagePermissionBody =>
      'Allow this app to see which apps you use so we can count today\'s time.';

  @override
  String get overlayPermissionTitle => 'Display over other apps';

  @override
  String get overlayPermissionBody =>
      'Allow a small glassy counter to float over other apps.';

  @override
  String get batteryPermissionTitle => 'Unrestricted battery';

  @override
  String get batteryPermissionBody =>
      'Allow unrestricted battery so the counter keeps running after you clear apps from Recents. Without this, Android kills the overlay to save battery.';

  @override
  String get grantUsageAccess => 'Open usage access';

  @override
  String get grantOverlayAccess => 'Open overlay settings';

  @override
  String get grantBatteryUnrestricted => 'Allow unrestricted battery';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionMissing => 'Required';

  @override
  String get continueToHome => 'Continue — counter starts automatically';

  @override
  String get startTracking => 'Enable live counter';

  @override
  String get stopTracking => 'Disable live counter';

  @override
  String get trackingActive =>
      'Live counter is on — open any app to see it at the top';

  @override
  String get trackingInactive => 'Live counter is off';

  @override
  String get noUsageYet => 'No app usage recorded for today yet.';

  @override
  String get currentApp => 'Current app';

  @override
  String get switchLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'Persian';

  @override
  String get refresh => 'Refresh';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get permissionsRequired =>
      'Usage access, overlay, and unrestricted battery are required for the live counter.';

  @override
  String secondsFormat(String time) {
    return '$time';
  }
}
