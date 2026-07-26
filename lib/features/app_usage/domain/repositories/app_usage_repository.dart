import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Contract for live app-usage tracking and permission helpers.
///
/// How to use:
/// ```dart
/// final either = await repository.getTodayUsage();
/// ```
///
/// Implementations live in the data layer and must not leak Android APIs upward.
abstract class AppUsageRepository {
  /// Returns today's usage list sorted by descending seconds.
  Future<Either<Failure, List<AppUsageEntity>>> getTodayUsage();

  /// Checks usage-access and overlay permissions.
  Future<Either<Failure, PermissionsStatus>> checkPermissions();

  /// Opens Android Usage Access settings.
  Future<Either<Failure, Unit>> requestUsagePermission();

  /// Opens Android Display-over-other-apps settings.
  Future<Either<Failure, Unit>> requestOverlayPermission();

  /// Starts the 1s polling loop, overlay, and live increments.
  Future<Either<Failure, Unit>> startLiveTracking();

  /// Stops polling and hides the overlay.
  Future<Either<Failure, Unit>> stopLiveTracking();

  /// Whether live tracking is currently active.
  bool get isTracking;

  /// Stream of today's usage snapshots while tracking (and after refresh).
  Stream<List<AppUsageEntity>> get usageStream;

  /// Stream of the current foreground package while tracking.
  Stream<AppUsageEntity?> get currentAppStream;
}
