import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/utils/duration_format.dart';

/// Local cache of today's seconds keyed by date + package.
///
/// How to use:
/// ```dart
/// await local.saveTodaySeconds({'com.app': 120});
/// final map = await local.loadTodaySeconds();
/// ```
///
/// Survives process death within the same calendar day so the live ticker
/// can resume from the last known totals.
class UsageLocalDataSource {
  /// Creates a cache backed by [SharedPreferences].
  UsageLocalDataSource(this._prefs);

  static const _secondsPrefix = 'usage_seconds_';
  static const _dateKey = 'usage_cache_date';

  final SharedPreferences _prefs;

  /// Loads today's package→seconds map, clearing stale days first.
  Future<Map<String, int>> loadTodaySeconds() async {
    await _ensureTodayBucket();
    final date = todayDateKey();
    final raw = _prefs.getString('$_secondsPrefix$date');
    // Empty cache on first run of the day is expected.
    if (raw == null || raw.isEmpty) return <String, int>{};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );
  }

  /// Persists today's package→seconds map under the current date key.
  Future<void> saveTodaySeconds(Map<String, int> secondsByPackage) async {
    await _ensureTodayBucket();
    final date = todayDateKey();
    await _prefs.setString(
      '$_secondsPrefix$date',
      jsonEncode(secondsByPackage),
    );
  }

  /// If the stored date is not today, wipe yesterday's bucket reference.
  Future<void> _ensureTodayBucket() async {
    final today = todayDateKey();
    final stored = _prefs.getString(_dateKey);
    // When the calendar day rolls over, start a fresh cache bucket.
    if (stored != today) {
      if (stored != null) {
        await _prefs.remove('$_secondsPrefix$stored');
      }
      await _prefs.setString(_dateKey, today);
    }
  }
}
