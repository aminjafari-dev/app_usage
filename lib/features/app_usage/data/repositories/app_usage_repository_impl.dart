import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_local_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_stats_data_source.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Concrete [AppUsageRepository] that polls UsageStats and drives the overlay.
///
/// How to use (via DI only):
/// ```dart
/// locator.registerLazySingleton<AppUsageRepository>(
///   () => AppUsageRepositoryImpl(...),
/// );
/// ```
class AppUsageRepositoryImpl implements AppUsageRepository {
  /// Wires usage, local cache, and overlay data sources together.
  AppUsageRepositoryImpl({
    required UsageStatsDataSource usageStatsDataSource,
    required UsageLocalDataSource localDataSource,
    required OverlayDataSource overlayDataSource,
  })  : _usageStats = usageStatsDataSource,
        _local = localDataSource,
        _overlay = overlayDataSource;

  final UsageStatsDataSource _usageStats;
  final UsageLocalDataSource _local;
  final OverlayDataSource _overlay;

  final _usageController =
      StreamController<List<AppUsageEntity>>.broadcast();
  final _currentAppController =
      StreamController<AppUsageEntity?>.broadcast();

  final Map<String, AppUsageEntity> _today = {};
  Timer? _timer;
  String? _activePackage;
  String _cacheDate = todayDateKey();
  bool _tracking = false;

  @override
  bool get isTracking => _tracking;

  @override
  Stream<List<AppUsageEntity>> get usageStream => _usageController.stream;

  @override
  Stream<AppUsageEntity?> get currentAppStream =>
      _currentAppController.stream;

  @override
  Future<Either<Failure, List<AppUsageEntity>>> getTodayUsage() async {
    try {
      await _hydrateToday();
      return Right(_sortedToday());
    } catch (e) {
      return Left(PlatformFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PermissionsStatus>> checkPermissions() async {
    try {
      final usage = await _usageStats.hasUsagePermission();
      final overlay = await _overlay.hasPermission();
      return Right(
        PermissionsStatus(
          hasUsageAccess: usage,
          hasOverlayAccess: overlay,
        ),
      );
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestUsagePermission() async {
    try {
      await _usageStats.requestUsagePermission();
      return const Right(unit);
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestOverlayPermission() async {
    try {
      await _overlay.requestPermission();
      return const Right(unit);
    } catch (e) {
      return Left(PermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> startLiveTracking() async {
    try {
      final permissions = await checkPermissions();
      final status = permissions.fold<PermissionsStatus?>(
        (_) => null,
        (s) => s,
      );
      // Both special permissions must be granted before polling starts.
      if (status == null || !status.isReady) {
        return const Left(
          PermissionFailure('Usage access and overlay permission are required'),
        );
      }

      await _local.setAutoTrackingEnabled(true);
      await _hydrateToday();
      // Force restart so the pill lands at the top center every start.
      await _overlay.show(forceRestart: true);
      _tracking = true;
      _timer?.cancel();
      // Poll every second for foreground changes and live increments.
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        unawaited(_onTick());
      });
      await _onTick();
      return const Right(unit);
    } catch (e) {
      _tracking = false;
      return Left(PlatformFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> stopLiveTracking() async {
    try {
      _timer?.cancel();
      _timer = null;
      _tracking = false;
      _activePackage = null;
      await _local.setAutoTrackingEnabled(false);
      await _overlay.hide();
      _currentAppController.add(null);
      _emitUsage();
      return const Right(unit);
    } catch (e) {
      return Left(PlatformFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> ensureAutoTrackingStarted() async {
    try {
      // Already running — nothing to do.
      if (_tracking) return const Right(unit);

      // User previously tapped Stop — respect that until they Start again.
      if (!_local.isAutoTrackingEnabled()) return const Right(unit);

      final permissions = await checkPermissions();
      final status = permissions.fold<PermissionsStatus?>(
        (_) => null,
        (s) => s,
      );
      // Wait until both Android special permissions are granted.
      if (status == null || !status.isReady) return const Right(unit);

      return await startLiveTracking();
    } catch (e) {
      return Left(PlatformFailure(e.toString()));
    }
  }

  /// Merges UsageStats aggregates with the local live cache (max per package).
  Future<void> _hydrateToday() async {
    await _rollDayIfNeeded();
    final aggregates = await _usageStats.queryTodayAggregates();
    final cached = await _local.loadTodaySeconds();

    for (final model in aggregates) {
      final cachedSeconds = cached[model.packageName] ?? 0;
      // Prefer the larger value so we never lose live-ticker progress.
      final seconds = model.todaySeconds > cachedSeconds
          ? model.todaySeconds
          : cachedSeconds;
      _today[model.packageName] = AppUsageEntity(
        packageName: model.packageName,
        appName: model.appName,
        todaySeconds: seconds,
        iconBytes: model.iconBytes,
      );
    }

    // Keep packages that only exist in the live cache (rare but possible).
    for (final entry in cached.entries) {
      if (_today.containsKey(entry.key)) continue;
      final name = await _usageStats.resolveAppName(entry.key);
      final icon = await _usageStats.resolveIcon(entry.key);
      _today[entry.key] = AppUsageEntity(
        packageName: entry.key,
        appName: name,
        todaySeconds: entry.value,
        iconBytes: icon,
      );
    }

    _emitUsage();
  }

  /// One-second loop: detect foreground app, increment, persist, push overlay.
  Future<void> _onTick() async {
    if (!_tracking) return;
    try {
      await _rollDayIfNeeded();
      // Pass last active package so we keep counting after the 10s event gap.
      final package = await _usageStats.currentForegroundPackage(
        keepIfNoEvent: _activePackage,
      );

      // Launcher / our own app: pause counting and clear active target.
      if (package == null) {
        _activePackage = null;
        _emitUsage();
        return;
      }

      // App switch: resolve metadata once, then start incrementing.
      if (package != _activePackage) {
        _activePackage = package;
        if (!_today.containsKey(package)) {
          final name = await _usageStats.resolveAppName(package);
          final icon = await _usageStats.resolveIcon(package);
          _today[package] = AppUsageEntity(
            packageName: package,
            appName: name,
            todaySeconds: 0,
            iconBytes: icon,
          );
        }
      }

      final current = _today[package]!;
      final updated = current.copyWith(todaySeconds: current.todaySeconds + 1);
      _today[package] = updated;

      await _persistCache();
      _currentAppController.add(updated);
      _emitUsage();

      await _overlay.sendTick(
        OverlayTickPayload(
          packageName: updated.packageName,
          appName: updated.appName,
          todaySeconds: updated.todaySeconds,
        ),
      );
    } catch (_) {
      // Tick failures should not crash the timer; next second retries.
    }
  }

  Future<void> _persistCache() async {
    final map = <String, int>{
      for (final e in _today.entries) e.key: e.value.todaySeconds,
    };
    await _local.saveTodaySeconds(map);
  }

  Future<void> _rollDayIfNeeded() async {
    final today = todayDateKey();
    // At local midnight, wipe in-memory totals and re-seed from UsageStats.
    if (today != _cacheDate) {
      _cacheDate = today;
      _today.clear();
      _activePackage = null;
      await _local.loadTodaySeconds();
      final aggregates = await _usageStats.queryTodayAggregates();
      for (final model in aggregates) {
        _today[model.packageName] = AppUsageEntity(
          packageName: model.packageName,
          appName: model.appName,
          todaySeconds: model.todaySeconds,
          iconBytes: model.iconBytes,
        );
      }
    }
  }

  void _emitUsage() {
    if (!_usageController.isClosed) {
      _usageController.add(_sortedToday());
    }
  }

  List<AppUsageEntity> _sortedToday() {
    final list = _today.values.toList()
      ..sort((a, b) => b.todaySeconds.compareTo(a.todaySeconds));
    return list;
  }
}
