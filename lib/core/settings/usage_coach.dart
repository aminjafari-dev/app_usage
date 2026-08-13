import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/settings/app_timer_cubit.dart';
import 'package:app_usage/core/settings/coach_settings_cubit.dart';
import 'package:app_usage/core/utils/duration_format.dart';

/// Soft coach nudge shown when a per-app daily limit is exceeded.
///
/// How to use inside the overlay isolate:
/// ```dart
/// final decision = await coach.evaluate(
///   packageName: payload.packageName,
///   todaySeconds: payload.todaySeconds,
/// );
/// if (decision.shouldShow) showCoachCard(decision);
/// ```
class UsageCoach {
  /// Creates a coach backed by [SharedPreferences].
  UsageCoach(this._prefs);

  static const _stateKey = 'usage_coach_state_v1';

  /// Rotating supportive messages (l10n keys resolved in the UI).
  static const messageIds = <String>[
    'boss',
    'goal',
    'appsChange',
    'pause',
    'choice',
    'protect',
  ];

  final SharedPreferences _prefs;

  /// Latest preferences (reloaded on each evaluate).
  CoachSettings get settings => CoachSettingsCubit.readFrom(_prefs);

  /// Decides whether to show a coach card for the foreground app.
  ///
  /// Reloads prefs so limits/state written by the main isolate are visible.
  Future<CoachDecision> evaluate({
    required String packageName,
    required int todaySeconds,
  }) async {
    if (packageName.isEmpty) return CoachDecision.hide;

    try {
      await _prefs.reload();
    } catch (_) {
      // Continue with in-memory prefs if reload fails.
    }

    final coachSettings = settings;
    // Global Settings toggle off → never show coach cards.
    if (!coachSettings.enabled) return CoachDecision.hide;

    final limits = AppTimerCubit.readFrom(_prefs);
    final limit = limits[packageName];
    // No timer, or user turned reminders off for this app.
    if (limit == null || !limit.notify || limit.limitMinutes <= 0) {
      return CoachDecision.hide;
    }

    final limitSeconds = limit.limitMinutes * 60;
    if (todaySeconds < limitSeconds) return CoachDecision.hide;

    final state = _readState();
    final today = todayDateKey();
    final app = state.appFor(packageName, today);
    final now = DateTime.now();

    if (app.mutedToday) return CoachDecision.hide;
    if (app.nudgeCount >= coachSettings.maxNudgesPerDay) {
      return CoachDecision.hide;
    }
    if (app.sessionAcknowledged) return CoachDecision.hide;
    if (app.snoozeUntil != null && now.isBefore(app.snoozeUntil!)) {
      return CoachDecision.hide;
    }

    final minutesOver = ((todaySeconds - limitSeconds) / 60).ceil().clamp(1, 999);
    final messageIndex = app.nextMessageIndex();

    return CoachDecision(
      shouldShow: true,
      packageName: packageName,
      minutesOver: minutesOver,
      limitMinutes: limit.limitMinutes,
      messageIndex: messageIndex,
      nudgeNumber: app.nudgeCount + 1,
      snoozeMinutes: coachSettings.snoozeMinutes,
      allowMuteToday: coachSettings.allowMuteToday,
    );
  }

  /// Clears per-session ack when the user leaves a limited app.
  ///
  /// Also applies a short cool-down so returning to the same app does not
  /// immediately re-open the coach card.
  Future<void> onAppSwitched(String? previousPackage) async {
    if (previousPackage == null || previousPackage.isEmpty) return;
    final state = _readState();
    final today = todayDateKey();
    final app = state.appFor(previousPackage, today);
    if (!app.sessionAcknowledged) return;
    final next = state.copyWithApp(
      previousPackage,
      app.copyWith(
        sessionAcknowledged: false,
        snoozeUntil: DateTime.now().add(settings.snoozeDuration),
      ),
      today,
    );
    await _writeState(next);
  }

  /// Records that a nudge was shown (increments daily count + message cursor).
  Future<void> markShown(CoachDecision decision) async {
    final state = _readState();
    final today = todayDateKey();
    final app = state.appFor(decision.packageName, today);
    final nextApp = app.copyWith(
      nudgeCount: app.nudgeCount + 1,
      lastMessageIndex: decision.messageIndex,
      snoozeUntil: null,
    );
    await _writeState(state.copyWithApp(decision.packageName, nextApp, today));
  }

  /// User chose snooze — hide until the configured interval elapses.
  Future<void> snooze(String packageName) async {
    final state = _readState();
    final today = todayDateKey();
    final app = state.appFor(packageName, today);
    final until = DateTime.now().add(settings.snoozeDuration);
    await _writeState(
      state.copyWithApp(
        packageName,
        app.copyWith(snoozeUntil: until, sessionAcknowledged: false),
        today,
      ),
    );
  }

  /// User acknowledged the nudge — no more cards until they leave this app.
  Future<void> acknowledge(String packageName) async {
    final state = _readState();
    final today = todayDateKey();
    final app = state.appFor(packageName, today);
    await _writeState(
      state.copyWithApp(
        packageName,
        app.copyWith(sessionAcknowledged: true, clearSnooze: true),
        today,
      ),
    );
  }

  /// Mutes coach cards for [packageName] until local midnight.
  Future<void> muteToday(String packageName) async {
    final state = _readState();
    final today = todayDateKey();
    final app = state.appFor(packageName, today);
    await _writeState(
      state.copyWithApp(
        packageName,
        app.copyWith(mutedToday: true, sessionAcknowledged: true),
        today,
      ),
    );
  }

  CoachDayState _readState() {
    final raw = _prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) return CoachDayState.empty;
    try {
      return CoachDayState.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return CoachDayState.empty;
    }
  }

  Future<void> _writeState(CoachDayState state) async {
    await _prefs.setString(_stateKey, jsonEncode(state.toJson()));
  }
}

/// Result of evaluating whether the overlay should show a coach card.
class CoachDecision extends Equatable {
  /// Creates a coach decision.
  const CoachDecision({
    required this.shouldShow,
    this.packageName = '',
    this.minutesOver = 0,
    this.limitMinutes = 0,
    this.messageIndex = 0,
    this.nudgeNumber = 1,
    this.snoozeMinutes = 5,
    this.allowMuteToday = true,
  });

  static const hide = CoachDecision(shouldShow: false);

  final bool shouldShow;
  final String packageName;
  final int minutesOver;
  final int limitMinutes;
  final int messageIndex;
  final int nudgeNumber;
  final int snoozeMinutes;
  final bool allowMuteToday;

  String get messageId {
    if (UsageCoach.messageIds.isEmpty) return 'boss';
    final i = messageIndex % UsageCoach.messageIds.length;
    return UsageCoach.messageIds[i];
  }

  @override
  List<Object?> get props => [
        shouldShow,
        packageName,
        minutesOver,
        limitMinutes,
        messageIndex,
        nudgeNumber,
        snoozeMinutes,
        allowMuteToday,
      ];
}

/// Persisted coach state for the local calendar day.
class CoachDayState extends Equatable {
  const CoachDayState({
    required this.date,
    required this.apps,
  });

  static const empty = CoachDayState(date: '', apps: {});

  final String date;
  final Map<String, CoachAppState> apps;

  CoachAppState appFor(String packageName, String today) {
    // Midnight roll: ignore yesterday’s counts/snoozes.
    if (date != today) return const CoachAppState();
    return apps[packageName] ?? const CoachAppState();
  }

  CoachDayState copyWithApp(
    String packageName,
    CoachAppState app,
    String today,
  ) {
    final base = date == today ? Map<String, CoachAppState>.from(apps) : <String, CoachAppState>{};
    base[packageName] = app;
    return CoachDayState(date: today, apps: base);
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'apps': apps.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory CoachDayState.fromJson(Map<String, dynamic> json) {
    final rawApps = json['apps'];
    final apps = <String, CoachAppState>{};
    if (rawApps is Map) {
      for (final entry in rawApps.entries) {
        if (entry.value is! Map) continue;
        apps[entry.key.toString()] = CoachAppState.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }
    }
    return CoachDayState(
      date: json['date'] as String? ?? '',
      apps: apps,
    );
  }

  @override
  List<Object?> get props => [date, apps];
}

/// Per-app coach counters for one day.
class CoachAppState extends Equatable {
  const CoachAppState({
    this.nudgeCount = 0,
    this.lastMessageIndex = -1,
    this.snoozeUntil,
    this.sessionAcknowledged = false,
    this.mutedToday = false,
  });

  final int nudgeCount;
  final int lastMessageIndex;
  final DateTime? snoozeUntil;
  final bool sessionAcknowledged;
  final bool mutedToday;

  /// Picks the next message, skipping a repeat of the last one when possible.
  int nextMessageIndex() {
    final count = UsageCoach.messageIds.length;
    if (count <= 1) return 0;
    if (lastMessageIndex < 0) return 0;
    return (lastMessageIndex + 1) % count;
  }

  CoachAppState copyWith({
    int? nudgeCount,
    int? lastMessageIndex,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
    bool? sessionAcknowledged,
    bool? mutedToday,
  }) {
    return CoachAppState(
      nudgeCount: nudgeCount ?? this.nudgeCount,
      lastMessageIndex: lastMessageIndex ?? this.lastMessageIndex,
      snoozeUntil: clearSnooze ? null : (snoozeUntil ?? this.snoozeUntil),
      sessionAcknowledged: sessionAcknowledged ?? this.sessionAcknowledged,
      mutedToday: mutedToday ?? this.mutedToday,
    );
  }

  Map<String, dynamic> toJson() => {
        'nudgeCount': nudgeCount,
        'lastMessageIndex': lastMessageIndex,
        'snoozeUntilMs': snoozeUntil?.millisecondsSinceEpoch,
        'sessionAcknowledged': sessionAcknowledged,
        'mutedToday': mutedToday,
      };

  factory CoachAppState.fromJson(Map<String, dynamic> json) {
    final ms = (json['snoozeUntilMs'] as num?)?.toInt();
    return CoachAppState(
      nudgeCount: (json['nudgeCount'] as num?)?.toInt() ?? 0,
      lastMessageIndex: (json['lastMessageIndex'] as num?)?.toInt() ?? -1,
      snoozeUntil: ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms),
      sessionAcknowledged: json['sessionAcknowledged'] as bool? ?? false,
      mutedToday: json['mutedToday'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        nudgeCount,
        lastMessageIndex,
        snoozeUntil,
        sessionAcknowledged,
        mutedToday,
      ];
}
