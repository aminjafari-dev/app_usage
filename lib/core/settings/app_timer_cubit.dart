import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Daily usage limit for one app.
///
/// How to use:
/// ```dart
/// final limit = AppTimerLimit(
///   packageName: 'com.instagram.android',
///   limitMinutes: 90,
///   notify: true,
/// );
/// ```
class AppTimerLimit extends Equatable {
  /// Creates an immutable per-app timer limit.
  const AppTimerLimit({
    required this.packageName,
    required this.limitMinutes,
    this.notify = true,
  });

  final String packageName;

  /// Daily cap in whole minutes (hours × 60 + minutes).
  final int limitMinutes;

  /// Whether to notify when the limit is reached.
  final bool notify;

  int get hours => limitMinutes ~/ 60;

  int get minutes => limitMinutes % 60;

  AppTimerLimit copyWith({
    String? packageName,
    int? limitMinutes,
    bool? notify,
  }) {
    return AppTimerLimit(
      packageName: packageName ?? this.packageName,
      limitMinutes: limitMinutes ?? this.limitMinutes,
      notify: notify ?? this.notify,
    );
  }

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'limitMinutes': limitMinutes,
        'notify': notify,
      };

  factory AppTimerLimit.fromJson(Map<String, dynamic> json) {
    return AppTimerLimit(
      packageName: json['packageName'] as String? ?? '',
      limitMinutes: (json['limitMinutes'] as num?)?.toInt() ?? 0,
      notify: json['notify'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [packageName, limitMinutes, notify];
}

/// Persists per-app daily timers in [SharedPreferences].
///
/// How to use:
/// ```dart
/// context.read<AppTimerCubit>().setLimit(limit);
/// final existing = context.watch<AppTimerCubit>().limitFor(package);
/// ```
class AppTimerCubit extends Cubit<Map<String, AppTimerLimit>> {
  /// Creates a cubit backed by [SharedPreferences].
  AppTimerCubit(this._prefs) : super(const {});

  static const _prefsKey = 'app_timer_limits_v1';

  final SharedPreferences _prefs;

  /// Loads saved limits into state. Call once at app start.
  void load() {
    emit(readFrom(_prefs));
  }

  /// Reads persisted limits (also used by the overlay isolate).
  ///
  /// How to use: call after [SharedPreferences.reload] so the coach sees
  /// limits saved by the main app.
  static Map<String, AppTimerLimit> readFrom(SharedPreferences prefs) {
    return _readAll(prefs);
  }

  /// Returns the saved limit for [packageName], if any.
  AppTimerLimit? limitFor(String packageName) => state[packageName];

  /// Saves or updates [limit] for its package.
  Future<void> setLimit(AppTimerLimit limit) async {
    if (limit.packageName.isEmpty || limit.limitMinutes <= 0) return;
    final next = Map<String, AppTimerLimit>.from(state)
      ..[limit.packageName] = limit;
    emit(next);
    await _writeAll(next);
  }

  /// Removes the timer for [packageName].
  Future<void> clearLimit(String packageName) async {
    if (!state.containsKey(packageName)) return;
    final next = Map<String, AppTimerLimit>.from(state)..remove(packageName);
    emit(next);
    await _writeAll(next);
  }

  Future<void> _writeAll(Map<String, AppTimerLimit> limits) async {
    final encoded = jsonEncode(
      limits.values.map((e) => e.toJson()).toList(),
    );
    await _prefs.setString(_prefsKey, encoded);
  }

  static Map<String, AppTimerLimit> _readAll(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final map = <String, AppTimerLimit>{};
      for (final item in list) {
        if (item is! Map) continue;
        final limit = AppTimerLimit.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (limit.packageName.isEmpty || limit.limitMinutes <= 0) continue;
        map[limit.packageName] = limit;
      }
      return map;
    } catch (_) {
      return const {};
    }
  }
}
