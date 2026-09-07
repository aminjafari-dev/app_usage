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
  String get permissionsSubtitle => 'برای تجربه بهتر، دسترسی‌ها را فعال کنید';

  @override
  String get permissionAllow => 'اجازه';

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
  String get totalUsageLabel => 'مجموع استفاده امروز';

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

  @override
  String get navHome => 'خانه';

  @override
  String get navTimer => 'تایمر';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get navProfile => 'پروفایل';

  @override
  String get navAnalytics => 'آمار';

  @override
  String get analyticsTitle => 'آمار';

  @override
  String get analyticsPeriodThreeDays => '۳ روز';

  @override
  String get analyticsPeriodWeek => 'هفته';

  @override
  String get analyticsPeriodTenDays => '۱۰ روز';

  @override
  String get analyticsTotalLabel => 'مجموع زمان صفحه';

  @override
  String analyticsAveragePerDay(String duration) {
    return 'میانگین $duration در روز';
  }

  @override
  String get analyticsChartHeader => 'روند استفاده';

  @override
  String get analyticsAppsHeader => 'برنامه‌ها';

  @override
  String get analyticsNoData => 'در این بازه استفاده‌ای نیست';

  @override
  String get analyticsNoDataSubtitle =>
      'از برنامه‌ها استفاده کنید، سپس برای تازه‌سازی بکشید.';

  @override
  String get pressBackAgainToExit => 'برای خروج دوباره بازگشت را بزنید';

  @override
  String get tabComingSoon => 'این بخش به‌زودی اضافه می‌شود.';

  @override
  String get profileSubtitle => 'جزئیات پروفایل و حساب شما.';

  @override
  String get timerPickAppHint =>
      'برنامه‌ای را برای محدودیت روزانه یا مسدودسازی هنگام باز شدن انتخاب کنید.';

  @override
  String get timerSetDailyLimit => 'محدودیت استفاده روزانه را تنظیم کنید';

  @override
  String get timerHoursLabel => 'ساعت';

  @override
  String get timerMinutesLabel => 'دقیقه';

  @override
  String get timerNotifyWhenReached => 'یادآوری هنگام رسیدن به محدودیت';

  @override
  String get timerSetButton => 'تنظیم تایمر';

  @override
  String get timerSaved => 'محدودیت روزانه ذخیره شد.';

  @override
  String get timerInvalidLimit => 'زمانی بیشتر از صفر انتخاب کنید.';

  @override
  String get timerEmptyTitle => 'برنامه‌ای پیدا نشد';

  @override
  String get timerEmptySubtitle =>
      'برنامه‌های نصب‌شده پس از قابل‌مشاهده شدن اینجا نمایش داده می‌شوند.';

  @override
  String get timerSearchHint => 'جستجوی برنامه‌ها';

  @override
  String get timerSearchEmptyTitle => 'برنامه‌ای پیدا نشد';

  @override
  String get timerSearchEmptySubtitle => 'نام یا بسته دیگری را امتحان کنید.';

  @override
  String get timerNoLimitSet => 'بدون محدودیت';

  @override
  String get timerOtherAppsHeader => 'سایر برنامه‌ها';

  @override
  String timerLimitSummary(int hours, int minutes) {
    return 'محدودیت $hoursس $minutesد';
  }

  @override
  String timerLimitCompact(int hours, int minutes) {
    return '$hoursس $minutesد';
  }

  @override
  String get timerClearLimit => 'حذف محدودیت';

  @override
  String get timerLimitCleared => 'محدودیت روزانه حذف شد.';

  @override
  String get timerBlockWhenOpened => 'مسدود کردن این برنامه هنگام باز شدن';

  @override
  String get timerBlockWhenOpenedHint =>
      'قفل تمام‌صفحه نشان می‌دهد تا نتوان از برنامه استفاده کرد.';

  @override
  String get timerBlockedLabel => 'مسدود شده';

  @override
  String timerLimitAndBlockedSummary(int hours, int minutes) {
    return 'محدودیت $hoursس $minutesد · مسدود';
  }

  @override
  String get timerBlockSaved => 'مسدودسازی برنامه به‌روز شد.';

  @override
  String get blockTitle => 'برنامه مسدود است';

  @override
  String blockSubtitle(String appName) {
    return '$appName قفل شده است. برای ادامه، این برنامه را ترک کنید.';
  }

  @override
  String get blockLeaveButton => 'ترک برنامه';

  @override
  String get blockHint =>
      'شما این برنامه را مسدود کرده‌اید. تا زمانی که خارج نشوید قفل می‌ماند.';

  @override
  String get coachTitle => 'زمان بررسی';

  @override
  String coachOverLimitSubtitle(int minutes) {
    return 'شما $minutes دقیقه از محدودیت روزانه عبور کرده‌اید.';
  }

  @override
  String get coachMessageBoss => 'تو رئیس گوشی هستی — نه گوشی رئیس تو.';

  @override
  String get coachMessageGoal =>
      'هدفت را دنبال کن. این برنامه می‌تواند صبر کند.';

  @override
  String get coachMessageAppsChange => 'نگذار یک برنامه، روزت را عوض کند.';

  @override
  String get coachMessagePause =>
      'یک نفس بکش. بعد تصمیم بگیر هنوز می‌خواهی بمانی یا نه.';

  @override
  String get coachMessageChoice =>
      'محدودیت را برای دلیلی گذاشتی. به آن احترام بگذار.';

  @override
  String get coachMessageProtect =>
      'زمانی را که برای چیزهای مهم گذاشتی، حفظ کن.';

  @override
  String get coachMessageProtectPeace => 'آرامش‌ات را حفظ کن.';

  @override
  String get coachMessageProtectEnergy => 'انرژی‌ات را حفظ کن.';

  @override
  String get coachMessageTrustProcess => 'به فرایند اعتماد کن.';

  @override
  String get coachMessageProgressOverPerfection => 'پیشرفت مهم‌تر از کمال است.';

  @override
  String get coachMessageComparisonThief => 'مقایسه، دزد شادی است.';

  @override
  String get coachMessageDoneBetterPerfect =>
      'تمام‌کردن بهتر از کامل‌بودن است.';

  @override
  String get coachMessageDisciplineFreedom => 'انضباط برابر است با آزادی.';

  @override
  String get coachMessageStayHungry => 'گرسنه بمان. دیوانه‌وار بمان.';

  @override
  String get coachMessageBeSoGood => 'آن‌قدر خوب باش که نادیده‌ات نگیرند.';

  @override
  String get coachMessageImpossibleUntilDone =>
      'همیشه غیرممکن به نظر می‌رسد تا وقتی انجام شود.';

  @override
  String get coachMessageBelieveHalfway =>
      'باور کن که می‌توانی؛ نیمه‌ی راه را رفته‌ای.';

  @override
  String get coachMessageGettingStarted => 'راز پیشرفت، شروع‌کردن است.';

  @override
  String get coachMessageShotsYouDontTake =>
      'از شوت‌هایی که نمی‌زنی، صددرصد از دست می‌دهی.';

  @override
  String get coachMessageFallSeven => 'هفت بار زمین بخور، هشت بار بلند شو.';

  @override
  String get coachMessageStartWhereYouAre =>
      'از جایی که هستی شروع کن. با آنچه داری. هرچه می‌توانی انجام بده.';

  @override
  String get coachMessageRepeatedlyDo =>
      'ما همان چیزی هستیم که مدام تکرار می‌کنیم.';

  @override
  String get coachMessageLittleByLittle => 'ذره‌ذره، ذره زیاد می‌شود.';

  @override
  String get coachMessageProductiveNotBusy =>
      'روی مفیدبودن تمرکز کن، نه مشغول‌بودن.';

  @override
  String get coachMessageHardWorkTalent =>
      'کار سخت، استعداد را شکست می‌دهد وقتی استعداد سخت کار نکند.';

  @override
  String get coachMessageSuccessNotFinal =>
      'موفقیت پایان نیست، شکست هم مرگ نیست.';

  @override
  String get coachMessageSmallWins => 'پیروزی‌های کوچک هم حساب می‌شوند.';

  @override
  String get coachMessageRestProductive => 'استراحت هم سازنده است.';

  @override
  String get coachMessageDisciplineSelfLove => 'انضباط، عشق به خود است.';

  @override
  String get coachMessageDecisionsDistractions =>
      'تصمیم‌ها مهم‌تر از حواس‌پرتی‌ها.';

  @override
  String get coachMessageCameThisFar =>
      'تا اینجا نیامدی که فقط تا اینجا بیایی.';

  @override
  String get coachMessageMakeItExist => 'اول فقط بسازش. بعد می‌توانی خوبش کنی.';

  @override
  String get coachMessageWholePoint =>
      'تقریباً یادم رفته بود اصل ماجرا همین است.';

  @override
  String get coachMessageNextOpponent => 'حریف بعدی‌ات خودتی.';

  @override
  String get coachMessageFearRespect =>
      'از هیچ‌کس نمی‌ترسم، اما به همه احترام می‌گذارم.';

  @override
  String get coachMessageEmptyCup => 'از فنجان خالی نمی‌شود چیزی ریخت.';

  @override
  String get coachMessageFocusControl =>
      'روی چیزی تمرکز کن که کنترلش دست توست.';

  @override
  String get coachMessageLessScrolling => 'کمتر اسکرول. بیشتر زندگی.';

  @override
  String get coachMessageAttentionCurrency =>
      'توجه تو باارزش‌ترین سرمایه‌ات است.';

  @override
  String get coachMessageBePresent => 'در لحظه باش.';

  @override
  String get coachMessageOneDay => 'روز به روز.';

  @override
  String get coachMessageSmallSteps => 'هر روز قدم‌های کوچک.';

  @override
  String get coachMessageBuiltConsistency => 'ساخته‌شده با ثبات.';

  @override
  String get coachMessagePeacePriority => 'آرامش اولویت من است.';

  @override
  String get coachMessageDisciplineMotivation => 'انضباط مهم‌تر از انگیزه.';

  @override
  String get coachMessageKeepGoing => 'به هر حال ادامه بده.';

  @override
  String get coachMessageGrowthLooksGood => 'رشد بهت می‌آید.';

  @override
  String get coachMessageShowingUp => 'برای خودم حاضر می‌شوم.';

  @override
  String get coachMessageQuietGrind => 'فصل تلاش بی‌صدا.';

  @override
  String get coachMessageSoftBoundaries => 'زندگی نرم، مرزهای محکم.';

  @override
  String get coachMessageMainCharacter => 'انرژی شخصیت اصلی.';

  @override
  String get coachMessageHealingNotLinear => 'شفای درون خطی نیست.';

  @override
  String get coachMessageDoItScared => 'با ترس انجامش بده.';

  @override
  String get coachMessageComfortZones => 'چیزهای بزرگ از منطقه امن نمی‌آیند.';

  @override
  String get coachMessageDreamsDontWork =>
      'رؤیاها کار نمی‌کنند مگر تو کار کنی.';

  @override
  String get coachMessageBestTimeNow => 'بهترین زمان، همین حالا است.';

  @override
  String get coachMessageBeYourself =>
      'خودت باش؛ بقیه نقش‌ها قبلاً گرفته شده‌اند.';

  @override
  String get coachMessageStayHard => 'سخت بمان.';

  @override
  String get coachMessageWhoYouBecome =>
      'مقصد مهم نیست؛ مهم این است که کی می‌شوی.';

  @override
  String get coachMessageSilenceNoise => 'هیاهو را خاموش کن. به خودت گوش بده.';

  @override
  String get coachPauseButton => 'مکث می‌کنم';

  @override
  String coachSnoozeButton(int minutes) {
    return '$minutes دقیقه دیگر';
  }

  @override
  String get coachMuteToday => 'یادآوری این برنامه را امروز خاموش کن';

  @override
  String get coachSettingsTitle => 'یادآور محدودیت';

  @override
  String get coachSettingsSubtitle =>
      'یادآوری ملایم وقتی از محدودیت روزانه یک برنامه عبور می‌کنید.';

  @override
  String get coachSettingsEnabled => 'نمایش یادآور محدودیت';

  @override
  String get coachSettingsEnabledHint =>
      'هشدار روی نشان وقتی برنامه از محدودیت بگذرد';

  @override
  String get coachSettingsSnoozeLabel => 'فاصله تعویق';

  @override
  String get coachSettingsSnoozeHint => 'چقدر بعد از «دقیقه دیگر» صبر کند.';

  @override
  String get coachSettingsMaxNudgesLabel =>
      'حداکثر یادآوری در روز برای هر برنامه';

  @override
  String get coachSettingsMaxNudgesHint =>
      'یادآوری‌ها مفید بمانند، نه آزاردهنده.';

  @override
  String get coachSettingsAllowMute => 'اجازه «خاموش کردن امروز»';

  @override
  String get coachSettingsAllowMuteHint =>
      'دکمه‌ای برای بی‌صدا کردن یک برنامه تا فردا';

  @override
  String coachSettingsMinutes(int minutes) {
    return '$minutesد';
  }

  @override
  String coachSettingsSummary(int snooze, int max) {
    return 'تعویق $snoozeد · تا $max بار در روز';
  }

  @override
  String get coachSettingsOff => 'یادآوری‌ها خاموش است';

  @override
  String get coachAppearanceTitle => 'ظاهر گفتگو';

  @override
  String get coachAppearanceSubtitle => 'پیش‌نمایش نقل‌قول عبور از محدودیت';

  @override
  String get coachAppearancePreviewApp => 'برنامه نمونه';

  @override
  String get coachQuoteClose => 'بستن';

  @override
  String get coachLimitAlert => 'به محدودیت روزانه رسیدی';

  @override
  String get holidaySettingsTitle => 'روز تعطیل';

  @override
  String get holidaySettingsSubtitle =>
      'در این روز همه برنامه‌های مسدودشده آزادانه باز می‌شوند.';

  @override
  String holidaySettingsSummary(String day) {
    return '$day · آزادسازی برنامه‌های مسدود';
  }

  @override
  String get weekdayMonday => 'دوشنبه';

  @override
  String get weekdayTuesday => 'سه‌شنبه';

  @override
  String get weekdayWednesday => 'چهارشنبه';

  @override
  String get weekdayThursday => 'پنج‌شنبه';

  @override
  String get weekdayFriday => 'جمعه';

  @override
  String get weekdaySaturday => 'شنبه';

  @override
  String get weekdaySunday => 'یکشنبه';
}
