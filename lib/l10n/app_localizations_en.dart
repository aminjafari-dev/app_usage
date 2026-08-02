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
      'To help you find balance, we gently monitor your app usage. No harsh locks — just awareness on this device.';

  @override
  String get overlayPermissionTitle => 'Display over other apps';

  @override
  String get overlayPermissionBody =>
      'A small floating counter stays with you so you always know how much time you\'ve spent today.';

  @override
  String get batteryPermissionTitle => 'Unrestricted battery';

  @override
  String get batteryPermissionBody =>
      'Keep the counter alive after you clear Recents. Without this, Android may stop tracking to save battery.';

  @override
  String get grantAccess => 'Grant access';

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
  String permissionStep(int current, int total) {
    return '$current/$total';
  }

  @override
  String get continueNext => 'Continue';

  @override
  String get continueToHome => 'Continue — counter starts automatically';

  @override
  String get learnMorePrivacy => 'Learn more about privacy';

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
  String get noUsageYet => 'No usage yet...';

  @override
  String get noUsageYetSubtitle =>
      'Open apps on your phone to start tracking today\'s screen time.';

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
  String get permissionsRequiredHint =>
      'Grant the required access so the live counter can float over other apps.';

  @override
  String get todaySectionHeader => 'Today';

  @override
  String get trackingSectionHeader => 'Live counter';

  @override
  String get statusOnline => 'Tracking';

  @override
  String get statusOffline => 'Paused';

  @override
  String get quickRefresh => 'Refresh';

  @override
  String get quickLanguage => 'Language';

  @override
  String get quickSettings => 'Settings';

  @override
  String get quickPermissions => 'Access';

  @override
  String get openPermissions => 'Open permissions';

  @override
  String appsTracked(int count) {
    return '$count apps';
  }

  @override
  String get permissionsIntro =>
      'Allow the following so the floating counter can work like a Telegram overlay badge.';

  @override
  String get footerHintPermissions =>
      'Only this device can read usage stats. Nothing is uploaded.';

  @override
  String secondsFormat(String time) {
    return '$time';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsTrackerSection => 'Tracker';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get badgeAppearanceTitle => 'Badge Appearance';

  @override
  String get badgeAppearanceSubtitle => 'Size & Opacity';

  @override
  String get customizeBadgeTitle => 'Customize Badge';

  @override
  String get badgeSizeLabel => 'SIZE';

  @override
  String get badgeOpacityLabel => 'OPACITY';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';
}
