import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-chosen weekly holiday when blocked apps are temporarily unlocked.
///
/// [weekday] uses Dart's [DateTime] convention: Monday = 1 … Sunday = 7.
/// Default is Friday (common weekend day in many regions).
///
/// How to use:
/// ```dart
/// final holiday = context.watch<HolidaySettingsCubit>().state;
/// if (holiday.isActiveToday()) { /* skip blocks */ }
/// ```
class HolidaySettings extends Equatable {
  /// Creates holiday preferences.
  const HolidaySettings({
    this.weekday = DateTime.friday,
  });

  /// Day of week when blocked apps may be used freely.
  final int weekday;

  /// Default: Friday.
  static const HolidaySettings defaults = HolidaySettings();

  /// Valid [DateTime.weekday] values (1–7).
  static const List<int> weekdayOptions = [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  /// Whether [now] (or the device clock) falls on the configured holiday.
  bool isActiveToday([DateTime? now]) {
    final date = now ?? DateTime.now();
    return date.weekday == weekday;
  }

  HolidaySettings copyWith({int? weekday}) {
    return HolidaySettings(
      weekday: _snapWeekday(weekday ?? this.weekday),
    );
  }

  static int _snapWeekday(int value) {
    if (weekdayOptions.contains(value)) return value;
    return DateTime.friday;
  }

  @override
  List<Object?> get props => [weekday];
}

/// Persists and emits [HolidaySettings] for Settings UI + overlay blocking.
///
/// How to use:
/// ```dart
/// context.read<HolidaySettingsCubit>().save(
///   settings.copyWith(weekday: DateTime.saturday),
/// );
/// ```
class HolidaySettingsCubit extends Cubit<HolidaySettings> {
  /// Creates a cubit backed by [SharedPreferences].
  HolidaySettingsCubit(this._prefs) : super(HolidaySettings.defaults);

  static const _weekdayKey = 'holiday_weekday_v1';

  final SharedPreferences _prefs;

  /// Loads saved holiday day or falls back to Friday.
  void load() {
    emit(readFrom(_prefs));
  }

  /// Persists and emits [settings].
  Future<void> save(HolidaySettings settings) async {
    final next = settings.copyWith();
    await _prefs.setInt(_weekdayKey, next.weekday);
    emit(next);
  }

  /// Reads settings without a cubit (overlay isolate).
  static HolidaySettings readFrom(SharedPreferences prefs) {
    return HolidaySettings(
      weekday:
          prefs.getInt(_weekdayKey) ?? HolidaySettings.defaults.weekday,
    ).copyWith();
  }
}
