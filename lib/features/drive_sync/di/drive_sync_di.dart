import 'package:get_it/get_it.dart';

import 'package:app_usage/features/drive_sync/data/drive_sync_api.dart';
import 'package:app_usage/features/drive_sync/data/usage_pending_store.dart';
import 'package:app_usage/features/drive_sync/data/user_id_store.dart';
import 'package:app_usage/features/drive_sync/domain/drive_sync_service.dart';

/// Registers Drive sync dependencies that do not need [UsageLocalDataSource].
///
/// [DriveSyncService] is registered later from [setupAppUsageLocator] once
/// the usage local cache exists.
///
/// How to use: called from [setupLocator] before app_usage DI.
Future<void> setupDriveSyncLocator(GetIt locator) async {
  locator.registerLazySingleton<UserIdStore>(
    () => UserIdStore(locator()),
  );
  locator.registerLazySingleton<UsagePendingStore>(
    () => UsagePendingStore(locator()),
  );
  locator.registerLazySingleton<DriveSyncApi>(DriveSyncApi.new);
}

/// Registers [DriveSyncService] after usage data sources exist.
void registerDriveSyncService(GetIt locator) {
  if (locator.isRegistered<DriveSyncService>()) return;
  locator.registerLazySingleton<DriveSyncService>(
    () => DriveSyncService(
      userIdStore: locator(),
      pendingStore: locator(),
      localUsage: locator(),
      api: locator(),
    ),
  );
}
