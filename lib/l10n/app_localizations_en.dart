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
  String get permissionsSubtitle => 'Allow permissions for a better experience';

  @override
  String get permissionAllow => 'Allow';

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
  String get totalUsageLabel => 'Total usage today';

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

  @override
  String get navHome => 'Home';

  @override
  String get navTimer => 'Timer';

  @override
  String get navSettings => 'Settings';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsPeriodThreeDays => '3 Days';

  @override
  String get analyticsPeriodWeek => 'Week';

  @override
  String get analyticsPeriodTenDays => '10 Days';

  @override
  String get analyticsTotalLabel => 'Total screen time';

  @override
  String analyticsAveragePerDay(String duration) {
    return 'Avg $duration / day';
  }

  @override
  String get analyticsChartHeader => 'Usage over time';

  @override
  String get analyticsAppsHeader => 'Apps';

  @override
  String get analyticsNoData => 'No usage in this period';

  @override
  String get analyticsNoDataSubtitle =>
      'Use apps on this phone, then pull to refresh.';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get tabComingSoon => 'This section is coming soon.';

  @override
  String get profileSubtitle => 'Your profile and account details.';

  @override
  String get timerPickAppHint =>
      'Choose an app to set a daily limit or block it when opened.';

  @override
  String get timerSetDailyLimit => 'Set daily usage limit';

  @override
  String get timerHoursLabel => 'HOURS';

  @override
  String get timerMinutesLabel => 'MINUTES';

  @override
  String get timerNotifyWhenReached => 'Remind me when limit reached';

  @override
  String get timerSetButton => 'Set Timer';

  @override
  String get timerSaved => 'Daily limit saved.';

  @override
  String get timerInvalidLimit => 'Choose a time greater than zero.';

  @override
  String get timerEmptyTitle => 'No apps found';

  @override
  String get timerEmptySubtitle =>
      'Installed apps will appear here once they are visible to the app.';

  @override
  String get timerSearchHint => 'Search apps';

  @override
  String get timerSearchEmptyTitle => 'No matching apps';

  @override
  String get timerSearchEmptySubtitle => 'Try a different name or package.';

  @override
  String get timerNoLimitSet => 'No limit set';

  @override
  String get timerOtherAppsHeader => 'Other apps';

  @override
  String timerLimitSummary(int hours, int minutes) {
    return 'Limit ${hours}h ${minutes}m';
  }

  @override
  String timerLimitCompact(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get timerClearLimit => 'Remove limit';

  @override
  String get timerLimitCleared => 'Daily limit removed.';

  @override
  String get timerBlockWhenOpened => 'Block this app when opened';

  @override
  String get timerBlockWhenOpenedHint =>
      'Shows a full-screen lock so the app cannot be used.';

  @override
  String get timerBlockedLabel => 'Blocked';

  @override
  String timerLimitAndBlockedSummary(int hours, int minutes) {
    return 'Limit ${hours}h ${minutes}m · Blocked';
  }

  @override
  String get timerBlockSaved => 'App block updated.';

  @override
  String get blockTitle => 'App blocked';

  @override
  String blockSubtitle(String appName) {
    return '$appName is locked. Leave this app to continue.';
  }

  @override
  String get blockLeaveButton => 'Leave app';

  @override
  String get blockHint =>
      'You chose to block this app. It stays locked until you leave.';

  @override
  String get coachTitle => 'Time check';

  @override
  String coachOverLimitSubtitle(int minutes) {
    return 'You\'re $minutes min over your daily limit.';
  }

  @override
  String get coachMessageBoss =>
      'You\'re the boss of the phone — not the other way around.';

  @override
  String get coachMessageGoal => 'Follow your goal. This app can wait.';

  @override
  String get coachMessageAppsChange => 'Don\'t let an app rewrite your day.';

  @override
  String get coachMessagePause =>
      'One breath. Then decide if you still want to stay.';

  @override
  String get coachMessageChoice => 'You chose a limit for a reason. Honor it.';

  @override
  String get coachMessageProtect =>
      'Protect the time you saved for what matters.';

  @override
  String get coachMessageProtectPeace => 'Protect your peace.';

  @override
  String get coachMessageProtectEnergy => 'Protect your energy.';

  @override
  String get coachMessageTrustProcess => 'Trust the process.';

  @override
  String get coachMessageProgressOverPerfection => 'Progress over perfection.';

  @override
  String get coachMessageComparisonThief => 'Comparison is the thief of joy.';

  @override
  String get coachMessageDoneBetterPerfect => 'Done is better than perfect.';

  @override
  String get coachMessageDisciplineFreedom => 'Discipline equals freedom.';

  @override
  String get coachMessageStayHungry => 'Stay hungry. Stay foolish.';

  @override
  String get coachMessageBeSoGood => 'Be so good they can\'t ignore you.';

  @override
  String get coachMessageImpossibleUntilDone =>
      'It always seems impossible until it\'s done.';

  @override
  String get coachMessageBelieveHalfway =>
      'Believe you can and you\'re halfway there.';

  @override
  String get coachMessageGettingStarted =>
      'The secret of getting ahead is getting started.';

  @override
  String get coachMessageShotsYouDontTake =>
      'You miss 100% of the shots you don\'t take.';

  @override
  String get coachMessageFallSeven => 'Fall seven times, stand up eight.';

  @override
  String get coachMessageStartWhereYouAre =>
      'Start where you are. Use what you have. Do what you can.';

  @override
  String get coachMessageRepeatedlyDo => 'We are what we repeatedly do.';

  @override
  String get coachMessageLittleByLittle =>
      'Little by little, a little becomes a lot.';

  @override
  String get coachMessageProductiveNotBusy =>
      'Focus on being productive instead of busy.';

  @override
  String get coachMessageHardWorkTalent =>
      'Hard work beats talent when talent doesn\'t work hard.';

  @override
  String get coachMessageSuccessNotFinal =>
      'Success is not final, failure is not fatal.';

  @override
  String get coachMessageSmallWins => 'Small wins still count.';

  @override
  String get coachMessageRestProductive => 'Rest is productive too.';

  @override
  String get coachMessageDisciplineSelfLove => 'Discipline is self-love.';

  @override
  String get coachMessageDecisionsDistractions =>
      'Decisions over distractions.';

  @override
  String get coachMessageCameThisFar =>
      'You didn\'t come this far to only come this far.';

  @override
  String get coachMessageMakeItExist =>
      'Just make it exist first. You can make it good later.';

  @override
  String get coachMessageWholePoint =>
      'Almost forgot this was the whole point.';

  @override
  String get coachMessageNextOpponent => 'Your next opponent is you.';

  @override
  String get coachMessageFearRespect => 'I fear no one, but respect everyone.';

  @override
  String get coachMessageEmptyCup => 'You can\'t pour from an empty cup.';

  @override
  String get coachMessageFocusControl => 'Focus on what you can control.';

  @override
  String get coachMessageLessScrolling => 'Less scrolling. More living.';

  @override
  String get coachMessageAttentionCurrency =>
      'Your attention is your most valuable currency.';

  @override
  String get coachMessageBePresent => 'Be present.';

  @override
  String get coachMessageOneDay => 'One day at a time.';

  @override
  String get coachMessageSmallSteps => 'Small steps every day.';

  @override
  String get coachMessageBuiltConsistency => 'Built by consistency.';

  @override
  String get coachMessagePeacePriority => 'Peace is my priority.';

  @override
  String get coachMessageDisciplineMotivation => 'Discipline over motivation.';

  @override
  String get coachMessageKeepGoing => 'Keep going anyway.';

  @override
  String get coachMessageGrowthLooksGood => 'Growth looks good on you.';

  @override
  String get coachMessageShowingUp => 'Showing up for myself.';

  @override
  String get coachMessageQuietGrind => 'Quiet grind season.';

  @override
  String get coachMessageSoftBoundaries => 'Soft life, strong boundaries.';

  @override
  String get coachMessageMainCharacter => 'Main character energy.';

  @override
  String get coachMessageHealingNotLinear => 'Healing is not linear.';

  @override
  String get coachMessageDoItScared => 'Do it scared.';

  @override
  String get coachMessageComfortZones =>
      'Great things never come from comfort zones.';

  @override
  String get coachMessageDreamsDontWork => 'Dreams don\'t work unless you do.';

  @override
  String get coachMessageBestTimeNow => 'The best time is now.';

  @override
  String get coachMessageBeYourself =>
      'Be yourself; everyone else is already taken.';

  @override
  String get coachMessageStayHard => 'Stay hard.';

  @override
  String get coachMessageWhoYouBecome =>
      'It\'s not about the destination, it\'s who you become.';

  @override
  String get coachMessageSilenceNoise =>
      'Silence the noise. Listen to yourself.';

  @override
  String get coachPauseButton => 'I\'ll pause';

  @override
  String coachSnoozeButton(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes more minutes',
      one: '1 more minute',
    );
    return '$_temp0';
  }

  @override
  String get coachMuteToday => 'Mute reminders for this app today';

  @override
  String get coachSettingsTitle => 'Limit reminders';

  @override
  String get coachSettingsSubtitle =>
      'Gentle check-ins when you go past a daily app limit.';

  @override
  String get coachSettingsEnabled => 'Show limit reminders';

  @override
  String get coachSettingsEnabledHint =>
      'Alert on the badge when a timed app goes over its limit';

  @override
  String get coachSettingsSnoozeLabel => 'Snooze interval';

  @override
  String get coachSettingsSnoozeHint =>
      'How long to wait after “more minutes”.';

  @override
  String get coachSettingsMaxNudgesLabel => 'Max reminders per app / day';

  @override
  String get coachSettingsMaxNudgesHint =>
      'Keeps reminders helpful instead of noisy.';

  @override
  String get coachSettingsAllowMute => 'Allow “mute today”';

  @override
  String get coachSettingsAllowMuteHint =>
      'Show a button to silence one app until tomorrow';

  @override
  String coachSettingsMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String coachSettingsSummary(int snooze, int max) {
    return 'Snooze ${snooze}m · up to $max / day';
  }

  @override
  String get coachSettingsOff => 'Reminders turned off';

  @override
  String get coachAppearanceTitle => 'Dialog Appearance';

  @override
  String get coachAppearanceSubtitle => 'Preview the over-limit quote';

  @override
  String get coachAppearancePreviewApp => 'Sample app';

  @override
  String get coachQuoteClose => 'Close';

  @override
  String get coachLimitAlert => 'Daily limit reached';

  @override
  String get holidaySettingsTitle => 'Holiday day';

  @override
  String get holidaySettingsSubtitle =>
      'On this day, every blocked app is allowed to open freely.';

  @override
  String holidaySettingsSummary(String day) {
    return '$day · blocked apps unlock';
  }

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';
}
