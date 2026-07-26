import 'package:get_it/get_it.dart';

import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_local_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_stats_data_source.dart';
import 'package:app_usage/features/app_usage/data/repositories/app_usage_repository_impl.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';
import 'package:app_usage/features/app_usage/domain/usecases/check_permissions_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/ensure_auto_tracking_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/get_today_usage_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/request_overlay_permission_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/request_usage_permission_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/start_live_tracking_usecase.dart';
import 'package:app_usage/features/app_usage/domain/usecases/stop_live_tracking_usecase.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_bloc.dart';

/// Registers app_usage feature dependencies into [locator].
///
/// How to use: called from [setupLocator] in the core locator file.
Future<void> setupAppUsageLocator(GetIt locator) async {
  // Data sources
  locator.registerLazySingleton<UsageStatsDataSource>(
    UsageStatsDataSource.new,
  );
  locator.registerLazySingleton<UsageLocalDataSource>(
    () => UsageLocalDataSource(locator()),
  );
  locator.registerLazySingleton<OverlayDataSource>(OverlayDataSource.new);

  // Repository
  locator.registerLazySingleton<AppUsageRepository>(
    () => AppUsageRepositoryImpl(
      usageStatsDataSource: locator(),
      localDataSource: locator(),
      overlayDataSource: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(
    () => GetTodayUsageUseCase(locator()),
  );
  locator.registerLazySingleton(
    () => CheckPermissionsUseCase(locator()),
  );
  locator.registerLazySingleton(
    () => RequestUsagePermissionUseCase(locator()),
  );
  locator.registerLazySingleton(
    () => RequestOverlayPermissionUseCase(locator()),
  );
  locator.registerLazySingleton(
    () => StartLiveTrackingUseCase(locator()),
  );
  locator.registerLazySingleton(
    () => StopLiveTrackingUseCase(locator()),
  );
  locator.registerLazySingleton(
    () => EnsureAutoTrackingUseCase(locator()),
  );

  // BLoC — factory so each page gets a fresh instance.
  locator.registerFactory(
    () => UsageBloc(
      checkPermissionsUseCase: locator(),
      requestUsagePermissionUseCase: locator(),
      requestOverlayPermissionUseCase: locator(),
      getTodayUsageUseCase: locator(),
      startLiveTrackingUseCase: locator(),
      stopLiveTrackingUseCase: locator(),
      ensureAutoTrackingUseCase: locator(),
      repository: locator(),
    ),
  );
}
