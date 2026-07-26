import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Sealed events for [UsageBloc].
///
/// How to use:
/// ```dart
/// context.read<UsageBloc>().add(const UsageEvent.started());
/// ```
sealed class UsageEvent {
  const UsageEvent();

  /// Bootstrap permissions + today's list on page open.
  const factory UsageEvent.started() = UsageStarted;

  /// Refresh permission flags after returning from system settings.
  const factory UsageEvent.refreshPermissions() = UsageRefreshPermissions;

  /// Open Usage Access settings.
  const factory UsageEvent.requestUsagePermission() =
      UsageRequestUsagePermission;

  /// Open Display-over-other-apps settings.
  const factory UsageEvent.requestOverlayPermission() =
      UsageRequestOverlayPermission;

  /// Open Unrestricted battery dialog / settings.
  const factory UsageEvent.requestBatteryUnrestricted() =
      UsageRequestBatteryUnrestricted;

  /// Reload today's usage list from the repository.
  const factory UsageEvent.refreshUsage() = UsageRefreshUsage;

  /// Start the live overlay counter.
  const factory UsageEvent.startTracking() = UsageStartTracking;

  /// Stop the live overlay counter.
  const factory UsageEvent.stopTracking() = UsageStopTracking;

  /// Internal: repository pushed a new sorted today's list.
  const factory UsageEvent.usageUpdated(List<AppUsageEntity> apps) =
      UsageUpdated;

  /// Internal: repository pushed the current foreground app.
  const factory UsageEvent.currentAppUpdated(AppUsageEntity? app) =
      UsageCurrentAppUpdated;
}

/// See [UsageEvent.started].
class UsageStarted extends UsageEvent {
  const UsageStarted();
}

/// See [UsageEvent.refreshPermissions].
class UsageRefreshPermissions extends UsageEvent {
  const UsageRefreshPermissions();
}

/// See [UsageEvent.requestUsagePermission].
class UsageRequestUsagePermission extends UsageEvent {
  const UsageRequestUsagePermission();
}

/// See [UsageEvent.requestOverlayPermission].
class UsageRequestOverlayPermission extends UsageEvent {
  const UsageRequestOverlayPermission();
}

/// See [UsageEvent.requestBatteryUnrestricted].
class UsageRequestBatteryUnrestricted extends UsageEvent {
  const UsageRequestBatteryUnrestricted();
}

/// See [UsageEvent.refreshUsage].
class UsageRefreshUsage extends UsageEvent {
  const UsageRefreshUsage();
}

/// See [UsageEvent.startTracking].
class UsageStartTracking extends UsageEvent {
  const UsageStartTracking();
}

/// See [UsageEvent.stopTracking].
class UsageStopTracking extends UsageEvent {
  const UsageStopTracking();
}

/// See [UsageEvent.usageUpdated].
class UsageUpdated extends UsageEvent {
  const UsageUpdated(this.apps);

  final List<AppUsageEntity> apps;
}

/// See [UsageEvent.currentAppUpdated].
class UsageCurrentAppUpdated extends UsageEvent {
  const UsageCurrentAppUpdated(this.app);

  final AppUsageEntity? app;
}
