import 'package:flutter/foundation.dart';

import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_local_data_source.dart';
import 'package:app_usage/features/drive_sync/data/drive_sync_api.dart';
import 'package:app_usage/features/drive_sync/data/usage_pending_store.dart';
import 'package:app_usage/features/drive_sync/data/user_id_store.dart';
import 'package:app_usage/features/drive_sync/drive_sync_config.dart';

/// Archives finished days and uploads pending usage JSON to Drive via backend.
///
/// How to use:
/// ```dart
/// await driveSync.syncNow(); // on app open / noon worker
/// ```
class DriveSyncService {
  /// Creates the sync orchestrator.
  DriveSyncService({
    required UserIdStore this._userIdStore,
    required UsagePendingStore this._pendingStore,
    required UsageLocalDataSource this._localUsage,
    required DriveSyncApi this._api,
  });

  final UserIdStore _userIdStore;
  final UsagePendingStore _pendingStore;
  final UsageLocalDataSource _localUsage;
  final DriveSyncApi _api;

  bool _running = false;

  /// Stable anonymous id used as `usage_<id>.json` on Drive.
  Future<String> userId() => _userIdStore.getOrCreate();

  /// Enqueues a completed day (called on midnight rollover).
  Future<void> archiveDay(String date, Map<String, int> secondsByPackage) {
    return _pendingStore.enqueueDay(date, secondsByPackage);
  }

  /// Uploads all pending days (+ today's snapshot). Safe to call often.
  ///
  /// If the device is offline or the backend is down, pending data stays local
  /// and the next successful call catches up — including after a missed noon.
  Future<bool> syncNow() async {
    if (_running) return false;
    if (!DriveSyncConfig.isConfigured) {
      debugPrint(
        'DriveSyncService: set DRIVE_SYNC_URL to your Apps Script /exec URL',
      );
      return false;
    }
    _running = true;
    try {
      await _localUsage.reload();
      final today = todayDateKey();
      final todaySeconds = await _localUsage.loadTodaySeconds();
      if (todaySeconds.isNotEmpty) {
        await _pendingStore.enqueueDay(today, todaySeconds);
      }

      final pending = _pendingStore.loadPending();
      if (pending.isEmpty) return true;

      final id = await _userIdStore.getOrCreate();
      await _api.upload(userId: id, days: pending);
      await _pendingStore.markUploaded(pending.keys);
      return true;
    } catch (error, stack) {
      debugPrint('DriveSyncService.syncNow failed: $error\n$stack');
      return false;
    } finally {
      _running = false;
    }
  }
}
