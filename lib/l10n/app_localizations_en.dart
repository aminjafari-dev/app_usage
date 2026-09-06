// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shirin\'s Focus';

  @override
  String get homeTitle => 'Your day, my love';

  @override
  String get permissionsTitle => 'A few little permissions, Shirin jan';

  @override
  String get permissionsSubtitle =>
      'Just so I can look after your time, azizam';

  @override
  String get permissionAllow => 'Okay, love';

  @override
  String get unsupportedTitle => 'Aw… not this phone, joonam';

  @override
  String get unsupportedMessage =>
      'The live counter only works on Android — like a little gift meant for your phone.';

  @override
  String get usagePermissionTitle => 'Usage access';

  @override
  String get usagePermissionBody =>
      'Azizam, I just want to gently see how your day goes — no harsh locks, only love and awareness on this phone, made for you.';

  @override
  String get overlayPermissionTitle => 'Display over other apps';

  @override
  String get overlayPermissionBody =>
      'A soft little badge stays beside you, ghashangam, so you always know how your time is going.';

  @override
  String get batteryPermissionTitle => 'Unrestricted battery';

  @override
  String get batteryPermissionBody =>
      'Joonam, allow this so your counter doesn’t quietly disappear after you clear Recents — I want it to stay with you.';

  @override
  String get grantAccess => 'Let’s go, azizam';

  @override
  String get grantUsageAccess => 'Open usage access';

  @override
  String get grantOverlayAccess => 'Open overlay settings';

  @override
  String get grantBatteryUnrestricted => 'Allow unrestricted battery';

  @override
  String get permissionGranted => 'Well done, love 💕';

  @override
  String get permissionMissing => 'Still needed, ghashangam';

  @override
  String permissionStep(int current, int total) {
    return '$current/$total';
  }

  @override
  String get continueNext => 'Continue, azizam';

  @override
  String get continueToHome =>
      'Let’s go home — your counter turns on with love';

  @override
  String get learnMorePrivacy => 'Learn more about your privacy';

  @override
  String get startTracking => 'Turn the counter on, ghashangam';

  @override
  String get stopTracking => 'Turn it off for now';

  @override
  String get trackingActive =>
      'Counter is on, aziz delam — open any app and you’ll see it at the top';

  @override
  String get trackingInactive => 'Counter is off, joonam';

  @override
  String get noUsageYet => 'Nothing logged yet, golam…';

  @override
  String get noUsageYetSubtitle =>
      'Open some apps so I can see how your day went, Shirin jan.';

  @override
  String get currentApp => 'You’re here now';

  @override
  String get switchLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePersian => 'Persian';

  @override
  String get refresh => 'Refresh, azizam';

  @override
  String get errorGeneric =>
      'Oops, something went wrong azizam — try again, love.';

  @override
  String get permissionsRequired =>
      'Azizam, the live counter needs usage, overlay, and unrestricted battery.';

  @override
  String get permissionsRequiredHint =>
      'Grant access so this little helper can stay beside you with love.';

  @override
  String get todaySectionHeader => 'Your today';

  @override
  String get totalUsageLabel => 'Your total time today';

  @override
  String get trackingSectionHeader => 'Loving counter';

  @override
  String get statusOnline => 'Watching over you';

  @override
  String get statusOffline => 'Resting';

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
      'Allow these, ghashangam, so the floating badge can stay on your screen like a soft little kiss.';

  @override
  String get footerHintPermissions =>
      'Don’t worry azizam — only this phone reads your usage. Nothing goes anywhere.';

  @override
  String secondsFormat(String time) {
    return '$time';
  }

  @override
  String get settingsTitle => 'Your settings';

  @override
  String get settingsPreferencesSection => 'Your preferences';

  @override
  String get settingsTrackerSection => 'Looking after your time';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Soft light';

  @override
  String get themeDark => 'Calm night';

  @override
  String get badgeAppearanceTitle => 'Little badge look';

  @override
  String get badgeAppearanceSubtitle => 'Size & opacity — however you like';

  @override
  String get customizeBadgeTitle => 'Make the badge pretty';

  @override
  String get badgeSizeLabel => 'SIZE';

  @override
  String get badgeOpacityLabel => 'OPACITY';

  @override
  String get saveChanges => 'Save, azizam';

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
  String get pressBackAgainToExit => 'Press back again to leave, ghashangam';

  @override
  String get tabComingSoon => 'This part is coming soon — wait for me, azizam.';

  @override
  String get profileName => 'Shirin joonam';

  @override
  String get profileSubtitle =>
      'Made with all the love in the world — only for you, eshgham.';

  @override
  String get timerPickAppHint =>
      'Pick an app so I can set a daily limit or lock it for you, aziz delam.';

  @override
  String get timerSetDailyLimit => 'Set your daily limit';

  @override
  String get timerHoursLabel => 'HOURS';

  @override
  String get timerMinutesLabel => 'MINUTES';

  @override
  String get timerNotifyWhenReached =>
      'Remind me when I reach the limit, joonam';

  @override
  String get timerSetButton => 'Set it, ghashangam';

  @override
  String get timerSaved => 'Saved — I’m watching over your time, azizam.';

  @override
  String get timerInvalidLimit => 'Choose more than zero, golam.';

  @override
  String get timerEmptyTitle => 'No apps yet, Shirin jan';

  @override
  String get timerEmptySubtitle =>
      'Use some apps today, then come back and we’ll set it together.';

  @override
  String timerLimitSummary(int hours, int minutes) {
    return 'Limit ${hours}h ${minutes}m';
  }

  @override
  String get timerBlockWhenOpened => 'Lock this app when opened';

  @override
  String get timerBlockWhenOpenedHint =>
      'A soft full-screen lock appears to protect your time, azizam.';

  @override
  String get timerBlockedLabel => 'Locked with love';

  @override
  String timerLimitAndBlockedSummary(int hours, int minutes) {
    return 'Limit ${hours}h ${minutes}m · Locked';
  }

  @override
  String get timerBlockSaved => 'Okay azizam, lock updated.';

  @override
  String get blockTitle => 'Wait a second, ghashangam';

  @override
  String blockSubtitle(String appName) {
    return '$appName is locked right now. Leave so your day stays calm, azizam.';
  }

  @override
  String get blockLeaveButton => 'Okay, I’m leaving';

  @override
  String get blockHint =>
      'You asked for this lock to protect your time — it stays until you leave, joonam.';

  @override
  String get coachTitle => 'Hi eshgham';

  @override
  String coachOverLimitSubtitle(int minutes) {
    return 'Aziz delam, you’re $minutes min past your daily limit.';
  }

  @override
  String get coachMessageBoss =>
      'Shirin joonam, you’re the boss of this phone — not the other way around, azizam.';

  @override
  String get coachMessageGoal =>
      'Follow your goal, ghashangam. This app can wait.';

  @override
  String get coachMessageAppsChange =>
      'Don’t let an app ruin your beautiful day, aziz delam.';

  @override
  String get coachMessagePause =>
      'One soft breath, rooham. Then see if you still want to stay.';

  @override
  String get coachMessageChoice =>
      'You set this limit for yourself. Honor it, eshgham.';

  @override
  String get coachMessageProtect =>
      'Protect the time you saved for what matters, nazanin.';

  @override
  String get coachMessageProtectPeace =>
      'Your peace is gold, Shirin jan — keep it.';

  @override
  String get coachMessageProtectEnergy =>
      'Your energy is yours, golam — don’t waste it.';

  @override
  String get coachMessageTrustProcess =>
      'Trust yourself, azizam. You’re doing so beautifully.';

  @override
  String get coachMessageProgressOverPerfection =>
      'You don’t need to be perfect, joonam — just keep going.';

  @override
  String get coachMessageComparisonThief =>
      'Don’t compare yourself to anyone, ghashangam — you’re one of a kind.';

  @override
  String get coachMessageDoneBetterPerfect =>
      'Done is better than perfect, azizam.';

  @override
  String get coachMessageDisciplineFreedom =>
      'A soft bit of discipline means more freedom for you, eshgham.';

  @override
  String get coachMessageStayHungry =>
      'Stay curious, stay kind to yourself, rooham.';

  @override
  String get coachMessageBeSoGood =>
      'You’re already so good they can’t ignore you, Shirin joon.';

  @override
  String get coachMessageImpossibleUntilDone =>
      'It feels hard until you do it, ghashangam — and you can.';

  @override
  String get coachMessageBelieveHalfway =>
      'Believe you can, aziz delam — you’re already halfway there.';

  @override
  String get coachMessageGettingStarted =>
      'The secret? Just starting, golam. Start, love.';

  @override
  String get coachMessageShotsYouDontTake =>
      'What you never try, you lose — be brave, joonam.';

  @override
  String get coachMessageFallSeven =>
      'Fall seven times, stand up eight — I’m right here, eshgham.';

  @override
  String get coachMessageStartWhereYouAre =>
      'Start right where you are, nazanin. With what you have.';

  @override
  String get coachMessageRepeatedlyDo =>
      'We become our little habits — so choose the pretty ones, azizam.';

  @override
  String get coachMessageLittleByLittle =>
      'Little by little, ghashangam — slowly it grows.';

  @override
  String get coachMessageProductiveNotBusy =>
      'Busy isn’t the point — useful is, rooham.';

  @override
  String get coachMessageHardWorkTalent =>
      'Your effort is prettier than unused talent, Shirin jan.';

  @override
  String get coachMessageSuccessNotFinal =>
      'Success isn’t the end, failure isn’t either, azizam.';

  @override
  String get coachMessageSmallWins =>
      'Little wins still count with love, ghashangam.';

  @override
  String get coachMessageRestProductive =>
      'Rest is love too — give yourself a break, joonam.';

  @override
  String get coachMessageDisciplineSelfLove =>
      'Looking after yourself is self-love — and you deserve that love, aziz delam.';

  @override
  String get coachMessageDecisionsDistractions =>
      'Your sweet decisions matter more than mindless scrolling, eshgham.';

  @override
  String get coachMessageCameThisFar =>
      'You didn’t come this far just to stop here — keep going, azizam.';

  @override
  String get coachMessageMakeItExist =>
      'Just start first, then make it pretty, golam.';

  @override
  String get coachMessageWholePoint =>
      'Remember — you’re the point, not this screen, rooham.';

  @override
  String get coachMessageNextOpponent =>
      'Your main opponent is you — and you’re winning beautifully, Shirin joon.';

  @override
  String get coachMessageFearRespect =>
      'Be strong, be kind — just like you are, nazanin.';

  @override
  String get coachMessageEmptyCup =>
      'You can’t pour from an empty cup — fill yours first, azizam.';

  @override
  String get coachMessageFocusControl =>
      'Focus on what you can hold, ghashangam.';

  @override
  String get coachMessageLessScrolling =>
      'Less scrolling, more living — especially for you, eshgham.';

  @override
  String get coachMessageAttentionCurrency =>
      'Your attention is your most precious gift, joonam — don’t waste it.';

  @override
  String get coachMessageBePresent =>
      'Be right here, my Shirin — this moment is yours.';

  @override
  String get coachMessageOneDay =>
      'Day by day, soft and with love, aziz delam.';

  @override
  String get coachMessageSmallSteps =>
      'One little step every day, golam — that’s enough.';

  @override
  String get coachMessageBuiltConsistency =>
      'You’re built by consistency, not rush, ghashangam.';

  @override
  String get coachMessagePeacePriority =>
      'Your peace is my priority for you, rooham.';

  @override
  String get coachMessageDisciplineMotivation =>
      'When motivation fades, soft discipline helps, azizam.';

  @override
  String get coachMessageKeepGoing =>
      'Keep going — I’m so proud of you, eshgham.';

  @override
  String get coachMessageGrowthLooksGood =>
      'Growth looks so good on you, Shirin joon — prettier every day.';

  @override
  String get coachMessageShowingUp =>
      'Show up for yourself — you deserve it, nazanin.';

  @override
  String get coachMessageQuietGrind =>
      'Quiet soft grind season — you’re strong, joonam.';

  @override
  String get coachMessageSoftBoundaries =>
      'Soft life, strong boundaries — well done azizam.';

  @override
  String get coachMessageMainCharacter =>
      'You’re the main character of this story, ghashangam.';

  @override
  String get coachMessageHealingNotLinear =>
      'Healing isn’t a straight line — be gentle with yourself, rooham.';

  @override
  String get coachMessageDoItScared =>
      'Do it scared — you’re braver than you think, eshgham.';

  @override
  String get coachMessageComfortZones =>
      'Great things live outside the comfort zone, golam — take one step.';

  @override
  String get coachMessageDreamsDontWork =>
      'Dreams don’t work unless you do, Shirin jan.';

  @override
  String get coachMessageBestTimeNow => 'Best time? Right now, aziz delam.';

  @override
  String get coachMessageBeYourself =>
      'Be yourself — every other role is taken, ghashangam.';

  @override
  String get coachMessageStayHard =>
      'Stay soft, stay strong — the way I love you, joonam.';

  @override
  String get coachMessageWhoYouBecome =>
      'It’s not the destination — it’s who you become, rooham.';

  @override
  String get coachMessageSilenceNoise =>
      'Silence the noise. Listen to your heart, my Shirin.';

  @override
  String get coachPauseButton => 'Okay, I’ll pause azizam';

  @override
  String coachSnoozeButton(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes more minutes, joonam',
      one: '1 more minute, joonam',
    );
    return '$_temp0';
  }

  @override
  String get coachMuteToday => 'Mute this reminder for today, ghashangam';

  @override
  String get coachSettingsTitle => 'Soft reminders';

  @override
  String get coachSettingsSubtitle =>
      'A loving check-in when you go past a daily limit.';

  @override
  String get coachSettingsEnabled => 'Keep limit reminders on';

  @override
  String get coachSettingsEnabledHint =>
      'I’ll nudge you on the badge when an app goes over, azizam';

  @override
  String get coachSettingsSnoozeLabel => 'Snooze interval';

  @override
  String get coachSettingsSnoozeHint =>
      'How long should I wait after “more minutes”, joonam.';

  @override
  String get coachSettingsMaxNudgesLabel => 'Max reminders per day';

  @override
  String get coachSettingsMaxNudgesHint =>
      'Keep reminders sweet, not annoying.';

  @override
  String get coachSettingsAllowMute => 'Allow “mute today”';

  @override
  String get coachSettingsAllowMuteHint =>
      'A button to silence one app until tomorrow';

  @override
  String coachSettingsMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String coachSettingsSummary(int snooze, int max) {
    return 'Snooze ${snooze}m · up to $max / day';
  }

  @override
  String get coachSettingsOff => 'Reminders are off, azizam';

  @override
  String get coachAppearanceTitle => 'Dialog look';

  @override
  String get coachAppearanceSubtitle => 'Preview the loving messages';

  @override
  String get coachAppearancePreviewApp => 'Sample app';

  @override
  String get coachQuoteClose => 'Close';

  @override
  String get coachLimitAlert => 'You hit your daily limit, ghashangam';

  @override
  String get holidaySettingsTitle => 'Shirin joon’s free day';

  @override
  String get holidaySettingsSubtitle =>
      'On this day every lock opens — guilt-free scrolling, only for you eshgham.';

  @override
  String holidaySettingsSummary(String day) {
    return '$day · unlock with love';
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
