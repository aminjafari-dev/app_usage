import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-tunable options for the over-limit coach reminders.
///
/// How to use:
/// ```dart
/// final settings = context.watch<CoachSettingsCubit>().state;
/// Duration(minutes: settings.snoozeMinutes);
/// ```
class CoachSettings extends Equatable {
  /// Creates coach preference values.
  const CoachSettings({
    this.enabled = true,
    this.snoozeMinutes = 5,
    this.maxNudgesPerDay = 3,
    this.allowMuteToday = true,
  });

  /// Master switch — when false, no coach cards appear.
  final bool enabled;

  /// Minutes to wait after the user taps “snooze”.
  final int snoozeMinutes;

  /// Soft daily cap of coach cards per limited app.
  final int maxNudgesPerDay;

  /// Whether the coach card shows “Mute today”.
  final bool allowMuteToday;

  /// Allowed snooze intervals (minutes).
  static const List<int> snoozeOptions = [1, 5, 10, 15];

  /// Allowed daily nudge caps.
  static const List<int> maxNudgeOptions = [1, 2, 3, 5];

  static const CoachSettings defaults = CoachSettings();

  Duration get snoozeDuration => Duration(minutes: snoozeMinutes);

  CoachSettings copyWith({
    bool? enabled,
    int? snoozeMinutes,
    int? maxNudgesPerDay,
    bool? allowMuteToday,
  }) {
    return CoachSettings(
      enabled: enabled ?? this.enabled,
      snoozeMinutes: _snapSnooze(snoozeMinutes ?? this.snoozeMinutes),
      maxNudgesPerDay: _snapMaxNudges(maxNudgesPerDay ?? this.maxNudgesPerDay),
      allowMuteToday: allowMuteToday ?? this.allowMuteToday,
    );
  }

  static int _snapSnooze(int minutes) {
    if (snoozeOptions.contains(minutes)) return minutes;
    // Nearest allowed step.
    return snoozeOptions.reduce(
      (a, b) => (a - minutes).abs() <= (b - minutes).abs() ? a : b,
    );
  }

  static int _snapMaxNudges(int value) {
    if (maxNudgeOptions.contains(value)) return value;
    return maxNudgeOptions.reduce(
      (a, b) => (a - value).abs() <= (b - value).abs() ? a : b,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'snoozeMinutes': snoozeMinutes,
        'maxNudgesPerDay': maxNudgesPerDay,
        'allowMuteToday': allowMuteToday,
      };

  factory CoachSettings.fromMap(Map<dynamic, dynamic> map) {
    return CoachSettings(
      enabled: map['enabled'] as bool? ?? defaults.enabled,
      snoozeMinutes: (map['snoozeMinutes'] as num?)?.toInt() ?? defaults.snoozeMinutes,
      maxNudgesPerDay:
          (map['maxNudgesPerDay'] as num?)?.toInt() ?? defaults.maxNudgesPerDay,
      allowMuteToday: map['allowMuteToday'] as bool? ?? defaults.allowMuteToday,
    ).copyWith();
  }

  @override
  List<Object?> get props => [
        enabled,
        snoozeMinutes,
        maxNudgesPerDay,
        allowMuteToday,
      ];
}

/// Persists and emits [CoachSettings] for Settings UI + overlay coach.
///
/// How to use:
/// ```dart
/// context.read<CoachSettingsCubit>().save(
///   settings.copyWith(snoozeMinutes: 10),
/// );
/// ```
class CoachSettingsCubit extends Cubit<CoachSettings> {
  /// Creates a cubit backed by [SharedPreferences].
  CoachSettingsCubit(this._prefs) : super(CoachSettings.defaults);

  static const _enabledKey = 'coach_enabled_v1';
  static const _snoozeKey = 'coach_snooze_minutes_v1';
  static const _maxNudgesKey = 'coach_max_nudges_v1';
  static const _muteKey = 'coach_allow_mute_today_v1';

  final SharedPreferences _prefs;

  /// Loads saved coach preferences or falls back to defaults.
  void load() {
    emit(readFrom(_prefs));
  }

  /// Persists and emits [settings].
  Future<void> save(CoachSettings settings) async {
    final next = settings.copyWith();
    await _prefs.setBool(_enabledKey, next.enabled);
    await _prefs.setInt(_snoozeKey, next.snoozeMinutes);
    await _prefs.setInt(_maxNudgesKey, next.maxNudgesPerDay);
    await _prefs.setBool(_muteKey, next.allowMuteToday);
    emit(next);
  }

  /// Reads settings without a cubit (overlay isolate).
  static CoachSettings readFrom(SharedPreferences prefs) {
    return CoachSettings(
      enabled: prefs.getBool(_enabledKey) ?? CoachSettings.defaults.enabled,
      snoozeMinutes:
          prefs.getInt(_snoozeKey) ?? CoachSettings.defaults.snoozeMinutes,
      maxNudgesPerDay:
          prefs.getInt(_maxNudgesKey) ?? CoachSettings.defaults.maxNudgesPerDay,
      allowMuteToday:
          prefs.getBool(_muteKey) ?? CoachSettings.defaults.allowMuteToday,
    ).copyWith();
  }
}
