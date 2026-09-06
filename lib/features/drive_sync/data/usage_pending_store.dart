import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local queue of day buckets waiting to upload to Drive.
///
/// How to use:
/// ```dart
/// await pending.enqueueDay('2026-09-05', {'com.app': 120});
/// final days = pending.loadPending();
/// await pending.markUploaded(['2026-09-05']);
/// ```
class UsagePendingStore {
  /// Creates a pending store backed by [SharedPreferences].
  UsagePendingStore(this._prefs);

  static const _pendingKey = 'drive_sync_pending_days';
  static const _uploadedKey = 'drive_sync_uploaded_dates';
  static const _lastSyncKey = 'drive_sync_last_success_at';

  final SharedPreferences _prefs;

  /// Merges [secondsByPackage] into the pending map for [date].
  Future<void> enqueueDay(String date, Map<String, int> secondsByPackage) async {
    if (secondsByPackage.isEmpty) return;
    final pending = loadPending();
    final existing = Map<String, int>.from(pending[date] ?? const {});
    secondsByPackage.forEach((pkg, seconds) {
      existing[pkg] = seconds;
    });
    pending[date] = existing;
    await _prefs.setString(_pendingKey, jsonEncode(pending));
  }

  /// Returns date → package → seconds still waiting for upload.
  Map<String, Map<String, int>> loadPending() {
    final raw = _prefs.getString(_pendingKey);
    if (raw == null || raw.isEmpty) return <String, Map<String, int>>{};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((date, value) {
      final apps = (value as Map<String, dynamic>).map(
        (pkg, seconds) => MapEntry(pkg, (seconds as num).toInt()),
      );
      return MapEntry(date, apps);
    });
  }

  /// Removes successfully uploaded dates from the pending queue.
  Future<void> markUploaded(Iterable<String> dates) async {
    final pending = loadPending();
    final uploaded = _uploadedDates();
    for (final date in dates) {
      pending.remove(date);
      uploaded.add(date);
    }
    await _prefs.setString(_pendingKey, jsonEncode(pending));
    await _prefs.setStringList(_uploadedKey, uploaded.toList()..sort());
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Whether [date] was already marked uploaded at least once.
  bool wasUploaded(String date) => _uploadedDates().contains(date);

  /// Last successful sync timestamp, if any.
  DateTime? lastSuccessAt() {
    final raw = _prefs.getString(_lastSyncKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Set<String> _uploadedDates() {
    return _prefs.getStringList(_uploadedKey)?.toSet() ?? <String>{};
  }
}
