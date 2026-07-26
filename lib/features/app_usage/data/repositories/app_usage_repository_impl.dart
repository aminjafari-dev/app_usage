import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/utils/usage_time_calculator.dart';
import 'package:app_usage/features/app_usage/data/datasources/battery_optimization_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_local_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_stats_data_source.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Concrete [AppUsageRepository] that owns overlay lifecycle + Home sync.
///
/// Live second-by-second counting runs inside the **overlay isolate**
/// ([OverlayLiveTracker]), not here. That way the badge keeps growing when
/// this main isolate is backgrounded or killed from Recents.
///
/// How to use (via DI only):
/// ```dart
/// locator.registerLazySingleton<AppUsageRepository>(
///   () => AppUsageRepositoryImpl(...),
/// );
/// ```
class AppUsageRepositoryImpl implements AppUsageRepository {
  /// Wires usage, local cache, overlay, and battery data sources together.
  AppUsageRepositoryImpl({
    required UsageStatsDataSource usageStatsDataSource,
    required UsageLocalDataSource localDataSource,
    required OverlayDataSource overlayDataSource,
    required BatteryOptimizationDataSource batteryDataSource,
  })  : _usageStats = usageStatsDataSource,
        _local = localDataSource,
        _overlay = overlayDataSource,
        _battery = batteryDataSource {
    // Listen for ticks published by the overlay isolate while Home is open.
    // Subscription lives for the app process; repository is a lazy singleton.
    FlutterOverlayWindow.overlayListener.listen(_onOverlayMessage);
  }

  final UsageStatsDataSource _usageStats;
  final UsageLocalDataSource _local;
  final OverlayDataSource _overlay;
  final BatteryOptimizationDataSource _battery;

  final _usageController =
      StreamController<List<AppUsageEntity>>.broadcast();
  final _currentAppController =
      StreamController<AppUsageEntity?>.broadcast();

  final Map<String, AppUsageEntity> _today = {};
  Timer? _homeSyncTimer;
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
      final battery = await _battery.isUnrestricted();
      return Right(
        PermissionsStatus(
          hasUsageAccess: usage,
          hasOverlayAccess: overlay,
          hasBatteryUnrestricted: battery,
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
  Future<Either<Failure, Unit>> requestBatteryUnrestricted() async {
    try {
      // Prefer the one-tap system dialog; OEMs may still need Settings.
      await _battery.requestUnrestricted();
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
      // All three permissions must be granted before the overlay starts.
      if (status == null || !status.isReady) {
        return const Left(
          PermissionFailure(
            'Usage access, overlay, and unrestricted battery are required',
          ),
        );
      }

      await _local.setAutoTrackingEnabled(true);
      await _hydrateToday();

      // If the overlay service already survived a main-app kill, reuse it.
      final alreadyActive = await _overlay.isActive();
      if (!alreadyActive) {
        // Force restart so the pill lands at the top center on a fresh start.
        await _overlay.show(forceRestart: true);
      }

      // AlarmManager watchdog recovers the overlay after Recents Clear-all.
      await _battery.startWatchdog();

      _tracking = true;
      _startHomeSync();
      return const Right(unit);
    } catch (e) {
      _tracking = false;
      return Left(PlatformFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> stopLiveTracking() async {
    try {
      _stopHomeSync();
      _tracking = false;
      await _local.setAutoTrackingEnabled(false);
      await _battery.stopWatchdog();
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
      // Already attached in this isolate — nothing to do.
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

      // Overlay may still be counting after the main activity was killed.
      final alreadyActive = await _overlay.isActive();
      if (alreadyActive) {
        await _hydrateToday();
        await _battery.startWatchdog();
        _tracking = true;
        _startHomeSync();
        return const Right(unit);
      }

      return await startLiveTracking();
    } catch (e) {
      return Left(PlatformFailure(e.toString()));
    }
  }

  /// Applies a tick map published by [OverlayLiveTracker] via shareData.
  ///
  /// Useful while Home is open so the list and preview stay in sync without
  /// waiting for the 2s SharedPreferences poll.
  void _onOverlayMessage(dynamic event) {
    if (!_tracking) return;
    if (event is! Map) return;

    final packageName = event['packageName'] as String? ?? '';
    final appName = event['appName'] as String? ?? packageName;
    final todaySeconds = (event['todaySeconds'] as num?)?.toInt() ?? 0;
    if (packageName.isEmpty) return;

    // Icon is only sent on app switches; keep the previous logo otherwise.
    final rawIcon = event['iconBytes'];
    List<int>? iconFromOverlay;
    if (rawIcon is List) {
      iconFromOverlay = rawIcon.map((e) => (e as num).toInt()).toList();
    }

    final existing = _today[packageName];
    final updated = AppUsageEntity(
      packageName: packageName,
      appName: appName.isEmpty ? (existing?.appName ?? packageName) : appName,
      todaySeconds: todaySeconds,
      // Prefer fresh PackageManager bytes from the overlay; else keep cache.
      iconBytes: iconFromOverlay ?? existing?.iconBytes,
    );
    _today[packageName] = updated;

    // Optional full totals map keeps other rows fresh without a prefs reload.
    final totals = event['totals'];
    if (totals is Map) {
      for (final entry in totals.entries) {
        final pkg = entry.key.toString();
        final seconds = (entry.value as num?)?.toInt() ?? 0;
        final prev = _today[pkg];
        if (prev != null) {
          _today[pkg] = prev.copyWith(todaySeconds: seconds);
        } else {
          _today[pkg] = AppUsageEntity(
            packageName: pkg,
            appName: pkg == packageName ? updated.appName : pkg,
            todaySeconds: seconds,
          );
        }
      }
    }

    _currentAppController.add(updated);
    _emitUsage();
  }

  /// Light poll so Home recovers totals after SharedPreferences writes.
  ///
  /// The overlay isolate owns the real-time counter; this only refreshes the
  /// dashboard when the main app is open.
  void _startHomeSync() {
    _homeSyncTimer?.cancel();
    _homeSyncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_syncFromLocalCache());
    });
  }

  void _stopHomeSync() {
    _homeSyncTimer?.cancel();
    _homeSyncTimer = null;
  }

  Future<void> _syncFromLocalCache() async {
    if (!_tracking) return;
    try {
      // Overlay writes prefs from another isolate — reload native values first.
      await _local.reload();
      await _hydrateToday();
    } catch (_) {
      // Sync failures should not tear down tracking.
    }
  }

  /// Merges UsageStats aggregates with the local live cache (max per package).
  Future<void> _hydrateToday() async {
    await _rollDayIfNeeded();
    // Always reload so we see seconds written by the overlay isolate.
    await _local.reload();
    final aggregates = await _usageStats.queryTodayAggregates();
    final cached = await _local.loadTodaySeconds();

    for (final model in aggregates) {
      final cachedSeconds = cached[model.packageName] ?? 0;
      // Events are the day source of truth; only keep a slightly-ahead live cache.
      // Useful so yesterday's inflated SharedPreferences cannot win via max().
      final seconds = mergeTodaySeconds(
        eventSeconds: model.todaySeconds,
        cachedSeconds: cachedSeconds,
      );
      final prev = _today[model.packageName];
      _today[model.packageName] = AppUsageEntity(
        packageName: model.packageName,
        appName: model.appName,
        todaySeconds: seconds,
        iconBytes: model.iconBytes ?? prev?.iconBytes,
      );
    }

    // Keep packages that only exist in the live cache (rare but possible).
    for (final entry in cached.entries) {
      if (_today.containsKey(entry.key)) {
        final prev = _today[entry.key]!;
        // Only bump from cache when it is slightly ahead of the event total.
        final merged = mergeTodaySeconds(
          eventSeconds: prev.todaySeconds,
          cachedSeconds: entry.value,
        );
        if (merged > prev.todaySeconds) {
          _today[entry.key] = prev.copyWith(todaySeconds: merged);
        }
        continue;
      }
      final name = await _usageStats.resolveAppName(entry.key);
      final icon = await _usageStats.resolveIcon(entry.key);
      _today[entry.key] = AppUsageEntity(
        packageName: entry.key,
        appName: name,
        todaySeconds: entry.value,
        iconBytes: icon,
      );
    }

    // Overwrite SharedPreferences so a stale inflated day cache is corrected.
    await _local.saveTodaySeconds({
      for (final entry in _today.entries) entry.key: entry.value.todaySeconds,
    });

    _emitUsage();
  }

  Future<void> _rollDayIfNeeded() async {
    final today = todayDateKey();
    // At local midnight, wipe in-memory totals and re-seed from UsageStats.
    if (today != _cacheDate) {
      _cacheDate = today;
      _today.clear();
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
