import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/features/drive_sync/domain/drive_sync_service.dart';
import 'package:app_usage/features/drive_sync/drive_sync_config.dart';

const _dailyTask = 'drive_sync_daily';
const _dailyUnique = 'drive_sync_daily_unique';

/// Background entrypoint for WorkManager Drive sync.
@pragma('vm:entry-point')
void driveSyncCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await setupLocator();
      final ok = await locator<DriveSyncService>().syncNow();
      return ok;
    } catch (error, stack) {
      debugPrint('driveSyncCallbackDispatcher: $error\n$stack');
      return false;
    }
  });
}

/// Registers a best-effort daily sync aimed at local noon.
///
/// How to use: call once from [main] after [setupLocator].
/// Missed noon windows are recovered by [DriveSyncService.syncNow] on app open.
Future<void> scheduleDailyDriveSync() async {
  await Workmanager().initialize(driveSyncCallbackDispatcher);

  final delay = _delayUntilNextSyncHour();
  await Workmanager().registerPeriodicTask(
    _dailyUnique,
    _dailyTask,
    frequency: const Duration(hours: 24),
    initialDelay: delay,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

Duration _delayUntilNextSyncHour() {
  final now = DateTime.now();
  var next = DateTime(
    now.year,
    now.month,
    now.day,
    DriveSyncConfig.syncHourLocal,
  );
  if (!next.isAfter(now)) {
    next = next.add(const Duration(days: 1));
  }
  return next.difference(now);
}
