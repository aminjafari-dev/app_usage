import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/features/drive_sync/data/usage_pending_store.dart';

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
  ///
  /// When [pendingStore] is provided, yesterday's bucket is archived for Drive
  /// upload before it is cleared on day rollover.
  UsageLocalDataSource(this._prefs, {UsagePendingStore? this._pendingStore});

  static const _secondsPrefix = 'usage_seconds_';
  static const _dateKey = 'usage_cache_date';
  static const _autoTrackingKey = 'auto_tracking_enabled';

  final SharedPreferences _prefs;
  final UsagePendingStore? _pendingStore;

  /// Reloads native prefs so this isolate sees writes from the overlay isolate.
  ///
  /// How to use: call before [loadTodaySeconds] when the main app resumes and
  /// the overlay may have been incrementing while we were killed/backgrounded.
  /// Example: Home refresh after returning from Recents.
  Future<void> reload() => _prefs.reload();

  /// Whether the live counter should auto-start when permissions are ready.
  ///
  /// Defaults to true so opening any app shows the top counter without a
  /// manual Start tap. Stopping from Home turns this off until Start again.
  bool isAutoTrackingEnabled() {
    return _prefs.getBool(_autoTrackingKey) ?? true;
  }

  /// Persists the user's auto-tracking preference.
  Future<void> setAutoTrackingEnabled(bool enabled) async {
    await _prefs.setBool(_autoTrackingKey, enabled);
  }

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

  /// If the stored date is not today, archive then wipe yesterday's bucket.
  Future<void> _ensureTodayBucket() async {
    final today = todayDateKey();
    final stored = _prefs.getString(_dateKey);
    // When the calendar day rolls over, start a fresh cache bucket.
    if (stored != today) {
      if (stored != null) {
        final raw = _prefs.getString('$_secondsPrefix$stored');
        final pending = _pendingStore;
        if (pending != null && raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final map = decoded.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          );
          await pending.enqueueDay(stored, map);
        }
        await _prefs.remove('$_secondsPrefix$stored');
      }
      await _prefs.setString(_dateKey, today);
    }
  }
}
