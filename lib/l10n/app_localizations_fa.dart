// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'زمان استفاده';

  @override
  String get homeTitle => 'استفاده امروز';

  @override
  String get permissionsTitle => 'دسترسی‌ها';

  @override
  String get unsupportedTitle => 'پشتیبانی نمی‌شود';

  @override
  String get unsupportedMessage =>
      'شمارنده زنده روی برنامه‌ها فقط روی اندروید در دسترس است.';

  @override
  String get usagePermissionTitle => 'دسترسی به آمار استفاده';

  @override
  String get usagePermissionBody =>
      'برای کمک به تعادل دیجیتال، استفاده از برنامه‌ها را به‌آرامی دنبال می‌کنیم. بدون قفل سخت — فقط آگاهی روی همین دستگاه.';

  @override
  String get overlayPermissionTitle => 'نمایش روی برنامه‌های دیگر';

  @override
  String get overlayPermissionBody =>
      'یک شمارنده شناور کوچک همراه شما می‌ماند تا همیشه بدانید امروز چقدر وقت گذاشته‌اید.';

  @override
  String get batteryPermissionTitle => 'باتری بدون محدودیت';

  @override
  String get batteryPermissionBody =>
      'شمارنده را بعد از پاک‌کردن برنامه‌ها از پس‌زمینه زنده نگه می‌دارد. بدون این دسترسی اندروید ممکن است ردیابی را برای صرفه‌جویی در باتری متوقف کند.';

  @override
  String get grantAccess => 'دادن دسترسی';

  @override
  String get grantUsageAccess => 'باز کردن دسترسی استفاده';

  @override
  String get grantOverlayAccess => 'باز کردن تنظیمات روکش';

  @override
  String get grantBatteryUnrestricted => 'اجازه باتری بدون محدودیت';

  @override
  String get permissionGranted => 'داده شده';

  @override
  String get permissionMissing => 'لازم است';

  @override
  String permissionStep(int current, int total) {
    return '$current/$total';
  }

  @override
  String get continueNext => 'ادامه';

  @override
  String get continueToHome => 'ادامه — شمارنده به‌صورت خودکار شروع می‌شود';

  @override
  String get learnMorePrivacy => 'درباره حریم خصوصی بیشتر بدانید';

  @override
  String get startTracking => 'فعال‌سازی شمارنده زنده';

  @override
  String get stopTracking => 'غیرفعال‌سازی شمارنده زنده';

  @override
  String get trackingActive =>
      'شمارنده زنده روشن است — هر برنامه‌ای باز کنید تا بالای صفحه ببینید';

  @override
  String get trackingInactive => 'شمارنده زنده خاموش است';

  @override
  String get noUsageYet => 'هنوز استفاده‌ای نیست...';

  @override
  String get noUsageYetSubtitle =>
      'برنامه‌ها را باز کنید تا زمان صفحه امروز ثبت شود.';

  @override
  String get currentApp => 'برنامه فعلی';

  @override
  String get switchLanguage => 'زبان';

  @override
  String get languageEnglish => 'انگلیسی';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get refresh => 'به‌روزرسانی';

  @override
  String get errorGeneric => 'مشکلی پیش آمد';

  @override
  String get permissionsRequired =>
      'برای شمارنده زنده دسترسی استفاده، روکش و باتری بدون محدودیت لازم است.';

  @override
  String get permissionsRequiredHint =>
      'دسترسی‌های لازم را بدهید تا شمارنده زنده روی برنامه‌ها نمایش داده شود.';

  @override
  String get todaySectionHeader => 'امروز';

  @override
  String get trackingSectionHeader => 'شمارنده زنده';

  @override
  String get statusOnline => 'در حال ردیابی';

  @override
  String get statusOffline => 'متوقف';

  @override
  String get quickRefresh => 'تازه‌سازی';

  @override
  String get quickLanguage => 'زبان';

  @override
  String get quickSettings => 'تنظیمات';

  @override
  String get quickPermissions => 'دسترسی';

  @override
  String get openPermissions => 'باز کردن دسترسی‌ها';

  @override
  String appsTracked(int count) {
    return '$count برنامه';
  }

  @override
  String get permissionsIntro =>
      'موارد زیر را فعال کنید تا شمارنده شناور مثل نشان تلگرام کار کند.';

  @override
  String get footerHintPermissions =>
      'فقط همین دستگاه آمار استفاده را می‌خواند. چیزی آپلود نمی‌شود.';

  @override
  String secondsFormat(String time) {
    return '$time';
  }

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsPreferencesSection => 'ترجیحات';

  @override
  String get settingsTrackerSection => 'ردیاب';

  @override
  String get settingsTheme => 'پوسته';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get badgeAppearanceTitle => 'ظاهر نشان';

  @override
  String get badgeAppearanceSubtitle => 'اندازه و شفافیت';

  @override
  String get customizeBadgeTitle => 'سفارشی‌سازی نشان';

  @override
  String get badgeSizeLabel => 'اندازه';

  @override
  String get badgeOpacityLabel => 'شفافیت';

  @override
  String get saveChanges => 'ذخیره تغییرات';

  @override
  String get privacyPolicy => 'حریم خصوصی';

  @override
  String get termsOfService => 'شرایط استفاده';
}
