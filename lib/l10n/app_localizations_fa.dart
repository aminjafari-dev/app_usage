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
      'اجازه دهید ببینیم از کدام برنامه‌ها استفاده می‌کنید تا زمان امروز را بشماریم.';

  @override
  String get overlayPermissionTitle => 'نمایش روی برنامه‌های دیگر';

  @override
  String get overlayPermissionBody =>
      'اجازه دهید یک شمارنده شیشه‌ای کوچک روی برنامه‌های دیگر نمایش داده شود.';

  @override
  String get grantUsageAccess => 'باز کردن دسترسی استفاده';

  @override
  String get grantOverlayAccess => 'باز کردن تنظیمات روکش';

  @override
  String get permissionGranted => 'داده شده';

  @override
  String get permissionMissing => 'لازم است';

  @override
  String get continueToHome => 'ادامه — شمارنده به‌صورت خودکار شروع می‌شود';

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
  String get noUsageYet => 'هنوز استفاده‌ای برای امروز ثبت نشده است.';

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
  String get permissionsRequired => 'برای شمارنده زنده هر دو دسترسی لازم است.';

  @override
  String secondsFormat(String time) {
    return '$time';
  }
}
