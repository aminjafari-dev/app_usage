// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'تمرکز شیرین';

  @override
  String get homeTitle => 'امروزت، قشنگم';

  @override
  String get permissionsTitle => 'چند تا دسترسی کوچولو، شیرین جان';

  @override
  String get permissionsSubtitle => 'فقط برای اینکه مراقب وقتت باشم، عزیز دلم';

  @override
  String get permissionAllow => 'باشه عزیزم';

  @override
  String get unsupportedTitle => 'اوه… این گوشی نه، جونم';

  @override
  String get unsupportedMessage =>
      'شمارنده زنده فقط روی اندروید کار می‌کنه — مثل یک هدیه‌ی مخصوص برای گوشی تو.';

  @override
  String get usagePermissionTitle => 'دسترسی به آمار استفاده';

  @override
  String get usagePermissionBody =>
      'عزیزم، فقط می‌خوام بدونم روزت چطور می‌گذره — بدون قفل سخت، فقط با عشق و آگاهی روی همین گوشی، مخصوص تو.';

  @override
  String get overlayPermissionTitle => 'نمایش روی برنامه‌های دیگر';

  @override
  String get overlayPermissionBody =>
      'یک نشان کوچولوی نرم کنارته، قشنگم، تا همیشه بدونی وقتت چطور می‌گذره.';

  @override
  String get batteryPermissionTitle => 'باتری بدون محدودیت';

  @override
  String get batteryPermissionBody =>
      'جونم، اینو بده تا شمارنده‌ات بعد از پاک‌کردن برنامه‌ها غیب نشه — می‌خوام همیشه کنارت بمونه.';

  @override
  String get grantAccess => 'بزن بریم، عزیزم';

  @override
  String get grantUsageAccess => 'باز کردن دسترسی استفاده';

  @override
  String get grantOverlayAccess => 'باز کردن تنظیمات روکش';

  @override
  String get grantBatteryUnrestricted => 'اجازه باتری بدون محدودیت';

  @override
  String get permissionGranted => 'آفرین، دادی 💕';

  @override
  String get permissionMissing => 'هنوز مونده، قشنگم';

  @override
  String permissionStep(int current, int total) {
    return '$current/$total';
  }

  @override
  String get continueNext => 'ادامه بده، عزیزم';

  @override
  String get continueToHome => 'بریم خونه — شمارنده‌ات با عشق روشن می‌شه';

  @override
  String get learnMorePrivacy => 'درباره حریم خصوصی‌ات بیشتر بدون';

  @override
  String get startTracking => 'روشن کن شمارنده رو، قشنگم';

  @override
  String get stopTracking => 'خاموشش کن فعلاً';

  @override
  String get trackingActive =>
      'شمارنده روشنه، عزیز دلم — هر برنامه‌ای باز کن، بالای صفحه می‌بینی‌ش';

  @override
  String get trackingInactive => 'شمارنده خاموشه، جونم';

  @override
  String get noUsageYet => 'هنوز چیزی ثبت نشده، گلم…';

  @override
  String get noUsageYetSubtitle =>
      'برنامه‌ها رو باز کن تا ببینم امروزت چطور گذشته، شیرین جان.';

  @override
  String get currentApp => 'الان اینجایی';

  @override
  String get switchLanguage => 'زبان';

  @override
  String get languageEnglish => 'انگلیسی';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get refresh => 'تازه‌ش کن، عزیزم';

  @override
  String get errorGeneric => 'اوه، یه چیزی پیش اومد عزیزم — دوباره امتحان کن.';

  @override
  String get permissionsRequired =>
      'عزیزم، برای شمارنده زنده این سه دسترسی لازمه: استفاده، روکش و باتری.';

  @override
  String get permissionsRequiredHint =>
      'دسترسی‌ها رو بده تا این کمک‌کوچولو بتونه با عشق کنارت باشه.';

  @override
  String get todaySectionHeader => 'امروز تو';

  @override
  String get totalUsageLabel => 'مجموع وقت امروزت';

  @override
  String get trackingSectionHeader => 'شمارنده عاشقانه';

  @override
  String get statusOnline => 'مراقبتم';

  @override
  String get statusOffline => 'استراحت';

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
      'اینا رو بده قشنگم، تا شمارنده مثل یک بوسه‌ی نرم روی صفحه‌ات بمونه.';

  @override
  String get footerHintPermissions =>
      'نگران نباش عزیزم — فقط همین گوشی می‌خونه. هیچی جایی نمی‌ره.';

  @override
  String secondsFormat(String time) {
    return '$time';
  }

  @override
  String get settingsTitle => 'تنظیمات تو';

  @override
  String get settingsPreferencesSection => 'ترجیحات قشنگت';

  @override
  String get settingsTrackerSection => 'مراقبت از وقتت';

  @override
  String get settingsTheme => 'پوسته';

  @override
  String get themeLight => 'روشن و نرم';

  @override
  String get themeDark => 'شب آروم';

  @override
  String get badgeAppearanceTitle => 'ظاهر نشان کوچولو';

  @override
  String get badgeAppearanceSubtitle => 'اندازه و شفافیت، هر جور دوست داری';

  @override
  String get customizeBadgeTitle => 'نشان رو قشنگ کن';

  @override
  String get badgeSizeLabel => 'اندازه';

  @override
  String get badgeOpacityLabel => 'شفافیت';

  @override
  String get saveChanges => 'ذخیره کن، عزیزم';

  @override
  String get privacyPolicy => 'حریم خصوصی';

  @override
  String get termsOfService => 'شرایط استفاده';

  @override
  String get navHome => 'خونه';

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
  String get pressBackAgainToExit =>
      'یه بار دیگه برگشت بزن تا بری بیرون، قشنگم';

  @override
  String get tabComingSoon => 'این بخش به‌زودی می‌آد، صبر کن عزیزم.';

  @override
  String get profileName => 'شیرین جونم';

  @override
  String get profileSubtitle =>
      'با تمام عشق دنیا، فقط برای تو ساخته شده — عشقم.';

  @override
  String get profileSyncTitle => 'پشتیبان ابری';

  @override
  String profileSyncSubtitle(String userId) {
    return 'شناسه کاربر: $userId';
  }

  @override
  String get profileSyncNow => 'الان همگام‌سازی با Drive';

  @override
  String get profileSyncOk => 'همگام شد، عزیزم 💕';

  @override
  String get profileSyncFail => 'فعلاً نشد — بعداً دوباره تلاش می‌کنم';

  @override
  String get timerPickAppHint =>
      'برنامه‌ای انتخاب کن که برات محدودیت بذارم یا قفلش کنم، عزیز دلم.';

  @override
  String get timerSetDailyLimit => 'محدودیت روزانه‌ات رو تنظیم کن';

  @override
  String get timerHoursLabel => 'ساعت';

  @override
  String get timerMinutesLabel => 'دقیقه';

  @override
  String get timerNotifyWhenReached => 'یادآوری کن وقتی به حد رسیدی، جونم';

  @override
  String get timerSetButton => 'تنظیم کن، قشنگم';

  @override
  String get timerSaved => 'ذخیره شد — مواظب وقتت هستم، عزیزم.';

  @override
  String get timerInvalidLimit => 'یه وقت بیشتر از صفر انتخاب کن، گلم.';

  @override
  String get timerEmptyTitle => 'هنوز برنامه‌ای نیست، شیرین جان';

  @override
  String get timerEmptySubtitle =>
      'امروز یه کم از برنامه‌ها استفاده کن، بعد برگرد تا برات تنظیم کنیم.';

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
    return 'حد $hoursس $minutesد';
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
  String get timerBlockWhenOpened => 'وقتی باز شد قفلش کن';

  @override
  String get timerBlockWhenOpenedHint =>
      'یه قفل نرم تمام‌صفحه می‌آد تا از وقتت محافظت کنه، عزیزم.';

  @override
  String get timerBlockLockedHint =>
      'این برنامه همیشه قفل است و قابل تغییر نیست.';

  @override
  String get timerBlockedLabel => 'قفل شده با عشق';

  @override
  String get timerAlwaysBlockedLabel => 'همیشه قفل';

  @override
  String timerLimitAndBlockedSummary(int hours, int minutes) {
    return 'حد $hoursس $minutesد · قفل';
  }

  @override
  String get timerBlockSaved => 'اوکی عزیزم، قفل به‌روز شد.';

  @override
  String get blockTitle => 'وایسا یه لحظه، قشنگم';

  @override
  String blockSubtitle(String appName) {
    return '$appName الان قفله. بذار بری بیرون تا روزت آروم بمونه، عزیزم.';
  }

  @override
  String get blockLeaveButton => 'باشه، می‌رم بیرون';

  @override
  String get blockHint =>
      'این قفل رو خودت برای محافظت از وقتت خواستی — تا خارج نشی می‌مونه، جونم.';

  @override
  String get coachTitle => 'سلام عشقم';

  @override
  String coachOverLimitSubtitle(int minutes) {
    return 'عزیز دلم، $minutes دقیقه از حد روزانه رد شدی.';
  }

  @override
  String get coachMessageBoss =>
      'شیرین جونم، تو رئیس این گوشی هستی — نه گوشی رئیس تو، عزیزم.';

  @override
  String get coachMessageGoal =>
      'هدفت رو دنبال کن قشنگم. این برنامه می‌تونه صبر کنه.';

  @override
  String get coachMessageAppsChange =>
      'نگذار یه برنامه، روز قشنگت رو خراب کنه، عزیز دلم.';

  @override
  String get coachMessagePause =>
      'یه نفس نرم بکش، روحم. بعد ببین هنوز می‌خوای بمونی یا نه.';

  @override
  String get coachMessageChoice =>
      'این حد رو برای خودت گذاشتی. بهش احترام بذار، عشقم.';

  @override
  String get coachMessageProtect =>
      'وقتی که برای چیزای مهم گذاشتی رو حفظ کن، نازنینم.';

  @override
  String get coachMessageProtectPeace => 'آرامش‌ات طلاست، شیرین جان — حفظش کن.';

  @override
  String get coachMessageProtectEnergy => 'انرژی‌ات مال خودته، گلم — هدرش نده.';

  @override
  String get coachMessageTrustProcess =>
      'به خودت اعتماد کن، عزیزم. خیلی قشنگ داری پیش می‌ری.';

  @override
  String get coachMessageProgressOverPerfection =>
      'کامل بودن لازم نیست، جونم — فقط پیش رفتن کافیه.';

  @override
  String get coachMessageComparisonThief =>
      'با کسی مقایسه نکن خودتو، قشنگم — تو خودت یکتایی.';

  @override
  String get coachMessageDoneBetterPerfect =>
      'تموم کردن بهتر از کامل‌بازیه، عزیزم.';

  @override
  String get coachMessageDisciplineFreedom =>
      'یه انضباط نرم، یعنی آزادی بیشتر برای تو، عشقم.';

  @override
  String get coachMessageStayHungry =>
      'کنجکاو بمون، مهربون بمون با خودت، روحم.';

  @override
  String get coachMessageBeSoGood =>
      'تو از همین الان انقدر خوبی که نمی‌شه ندیدت، شیرین جون.';

  @override
  String get coachMessageImpossibleUntilDone =>
      'سخت به نظر می‌رسه تا وقتی انجامش بدی، قشنگم — تو می‌تونی.';

  @override
  String get coachMessageBelieveHalfway =>
      'باور کن می‌تونی، عزیز دلم — نیمه‌ی راه رو رفتی.';

  @override
  String get coachMessageGettingStarted =>
      'راز پیشرفت؟ شروع کردن، گلم. فقط شروع کن.';

  @override
  String get coachMessageShotsYouDontTake =>
      'چیزایی که امتحان نکنی، از دست می‌رن — شجاعت داشته باش، جونم.';

  @override
  String get coachMessageFallSeven =>
      'هفت بار بیفتی، هشت بار بلند شو — من کنارتتم، عشقم.';

  @override
  String get coachMessageStartWhereYouAre =>
      'از همین‌جایی که هستی شروع کن، نازنینم. با همون چیزی که داری.';

  @override
  String get coachMessageRepeatedlyDo =>
      'ما همون عادت‌های کوچیکیمونیم — پس قشنگ انتخاب کن، عزیزم.';

  @override
  String get coachMessageLittleByLittle =>
      'ذره‌ذره، قشنگم؛ آروم‌آروم بزرگ می‌شه.';

  @override
  String get coachMessageProductiveNotBusy =>
      'مشغول بودن مهم نیست — مفید بودن مهمه، روحم.';

  @override
  String get coachMessageHardWorkTalent =>
      'تلاشت قشنگ‌تر از استعداد خاموشه، شیرین جان.';

  @override
  String get coachMessageSuccessNotFinal =>
      'موفقیت تموم نمی‌شه، شکست هم آخر راه نیست، عزیزم.';

  @override
  String get coachMessageSmallWins =>
      'پیروزی‌های کوچیک هم عاشقانه حساب می‌شن، قشنگم.';

  @override
  String get coachMessageRestProductive =>
      'استراحت هم عشقه — به خودت استراحت بده، جونم.';

  @override
  String get coachMessageDisciplineSelfLove =>
      'مراقب خودت بودن، عشق به خودته — و تو لایق عشقی، عزیز دلم.';

  @override
  String get coachMessageDecisionsDistractions =>
      'تصمیم‌های قشنگت مهم‌تر از اسکرول بی‌هدفن، عشقم.';

  @override
  String get coachMessageCameThisFar =>
      'تا اینجا اومدی که فقط تا اینجا وایسی؟ نه عزیزم — ادامه بده.';

  @override
  String get coachMessageMakeItExist =>
      'اول فقط شروعش کن، بعد قشنگش می‌کنی، گلم.';

  @override
  String get coachMessageWholePoint =>
      'یادت باشه اصل ماجرا تو هستی، نه این صفحه، روحم.';

  @override
  String get coachMessageNextOpponent =>
      'حریف اصلیت خودتی — و داری قشنگ می‌بری، شیرین جون.';

  @override
  String get coachMessageFearRespect =>
      'قوی باش، مهربون باش — همون‌طور که هستی، نازنینم.';

  @override
  String get coachMessageEmptyCup =>
      'از فنجون خالی چیزی نمی‌ریزه — اول خودتو پر کن، عزیزم.';

  @override
  String get coachMessageFocusControl =>
      'روی چیزی تمرکز کن که دست خودته، قشنگم.';

  @override
  String get coachMessageLessScrolling =>
      'کمتر اسکرول، بیشتر زندگی — مخصوصاً برای تو، عشقم.';

  @override
  String get coachMessageAttentionCurrency =>
      'توجه تو باارزش‌ترین هدیه‌ته، جونم — هدرش نده.';

  @override
  String get coachMessageBePresent => 'همین‌جا باش، شیرین من — لحظه مال توئه.';

  @override
  String get coachMessageOneDay => 'روزبه‌روز، آروم و با عشق، عزیز دلم.';

  @override
  String get coachMessageSmallSteps => 'هر روز یه قدم کوچولو، گلم — کافیه.';

  @override
  String get coachMessageBuiltConsistency =>
      'با ثبات ساخته می‌شی، نه با عجله، قشنگم.';

  @override
  String get coachMessagePeacePriority => 'آرامش‌ات اولویت منه برای تو، روحم.';

  @override
  String get coachMessageDisciplineMotivation =>
      'وقتی انگیزه کم شد، انضباط نرم کمکت می‌کنه، عزیزم.';

  @override
  String get coachMessageKeepGoing => 'ادامه بده — بهت افتخار می‌کنم، عشقم.';

  @override
  String get coachMessageGrowthLooksGood =>
      'رشد خیلی بهت می‌آد، شیرین جون — قشنگ‌تری هر روز.';

  @override
  String get coachMessageShowingUp => 'برای خودت حاضر شو — لایقشی، نازنینم.';

  @override
  String get coachMessageQuietGrind => 'فصل تلاش آروم و نرم — تو قوی‌ای، جونم.';

  @override
  String get coachMessageSoftBoundaries =>
      'زندگی نرم، مرزهای محکم — آفرین عزیزم.';

  @override
  String get coachMessageMainCharacter => 'شخصیت اصلی این داستان تویی، قشنگم.';

  @override
  String get coachMessageHealingNotLinear =>
      'درمان خطی نیست — با خودت مهربون باش، روحم.';

  @override
  String get coachMessageDoItScared =>
      'با ترس هم انجامش بده — شجاع‌تری از چیزی که فکر می‌کنی، عشقم.';

  @override
  String get coachMessageComfortZones =>
      'چیزای بزرگ بیرون از منطقه امن میان، گلم — یه قدم بردار.';

  @override
  String get coachMessageDreamsDontWork =>
      'رؤیاها کار نمی‌کنن مگر تو کار کنی، شیرین جان.';

  @override
  String get coachMessageBestTimeNow => 'بهترین زمان؟ همین الان، عزیز دلم.';

  @override
  String get coachMessageBeYourself =>
      'خودت باش — بقیه نقش‌ها گرفته شدن، قشنگم.';

  @override
  String get coachMessageStayHard =>
      'نرم بمون، قوی بمون — همون‌طور که دوستت دارم، جونم.';

  @override
  String get coachMessageWhoYouBecome =>
      'مقصد مهم نیست؛ مهم اینه که کی می‌شی، روحم.';

  @override
  String get coachMessageSilenceNoise =>
      'هیاهو رو خاموش کن. به قلبت گوش بده، شیرین من.';

  @override
  String get coachPauseButton => 'باشه، مکث می‌کنم عزیزم';

  @override
  String coachSnoozeButton(int minutes) {
    return '$minutes دقیقه‌ی دیگه، جونم';
  }

  @override
  String get coachMuteToday => 'امروز این یادآوری رو خاموش کن، قشنگم';

  @override
  String get coachSettingsTitle => 'یادآورهای نرم';

  @override
  String get coachSettingsSubtitle =>
      'یه چک‌این عاشقانه وقتی از حد روزانه رد شی.';

  @override
  String get coachSettingsEnabled => 'یادآور محدودیت روشن باشه';

  @override
  String get coachSettingsEnabledHint =>
      'روی نشان بهت بگم وقتی برنامه از حد رد شد، عزیزم';

  @override
  String get coachSettingsSnoozeLabel => 'فاصله‌ی تعویق';

  @override
  String get coachSettingsSnoozeHint =>
      'بعد از «دقیقه‌ی دیگه» چقدر صبر کنم، جونم.';

  @override
  String get coachSettingsMaxNudgesLabel => 'حداکثر یادآوری در روز';

  @override
  String get coachSettingsMaxNudgesHint =>
      'یادآوری‌ها مهربون بمونن، نه اذیت‌کننده.';

  @override
  String get coachSettingsAllowMute => 'اجازه «امروز خاموش»';

  @override
  String get coachSettingsAllowMuteHint =>
      'دکمه‌ای برای بی‌صدا کردن یه برنامه تا فردا';

  @override
  String coachSettingsMinutes(int minutes) {
    return '$minutesد';
  }

  @override
  String coachSettingsSummary(int snooze, int max) {
    return 'تعویق $snoozeد · تا $max بار در روز';
  }

  @override
  String get coachSettingsOff => 'یادآوری‌ها خاموشن، عزیزم';

  @override
  String get coachAppearanceTitle => 'ظاهر گفتگو';

  @override
  String get coachAppearanceSubtitle => 'پیش‌نمایش پیام‌های عاشقانه';

  @override
  String get coachAppearancePreviewApp => 'برنامه نمونه';

  @override
  String get coachQuoteClose => 'بستن';

  @override
  String get coachLimitAlert => 'به حد روزانه‌ات رسیدی، قشنگم';

  @override
  String get holidaySettingsTitle => 'روز آزاد شیرین جون';

  @override
  String get holidaySettingsSubtitle =>
      'تو این روز همه‌ی قفل‌ها باز می‌شن — اسکرول بدون عذاب وجدان، فقط برای تو عشقم.';

  @override
  String holidaySettingsSummary(String day) {
    return '$day · آزادسازی با عشق';
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
