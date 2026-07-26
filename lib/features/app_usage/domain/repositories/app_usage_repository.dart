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

  /// Checks usage-access, overlay, and battery-unrestricted permissions.
  Future<Either<Failure, PermissionsStatus>> checkPermissions();

  /// Opens Android Usage Access settings.
  Future<Either<Failure, Unit>> requestUsagePermission();

  /// Opens Android Display-over-other-apps settings.
  Future<Either<Failure, Unit>> requestOverlayPermission();

  /// Opens the Unrestricted battery dialog / settings.
  ///
  /// Required so OEMs do not kill the overlay when Recents is cleared.
  Future<Either<Failure, Unit>> requestBatteryUnrestricted();

  /// Starts the overlay foreground service (live counting runs in overlay).
  ///
  /// Also turns auto-tracking on so the next app launch resumes the counter.
  Future<Either<Failure, Unit>> startLiveTracking();

  /// Stops the overlay foreground service and hides the badge.
  ///
  /// Also turns auto-tracking off until the user starts again.
  Future<Either<Failure, Unit>> stopLiveTracking();

  /// Starts tracking when permissions are ready and auto-tracking is enabled.
  ///
  /// How to use: call from Home/Permissions after checking access so the
  /// top counter appears automatically when the user opens another app.
  Future<Either<Failure, Unit>> ensureAutoTrackingStarted();

  /// Whether live tracking is currently active.
  bool get isTracking;

  /// Stream of today's usage snapshots while tracking (and after refresh).
  Stream<List<AppUsageEntity>> get usageStream;

  /// Stream of the current foreground package while tracking.
  Stream<AppUsageEntity?> get currentAppStream;
}
