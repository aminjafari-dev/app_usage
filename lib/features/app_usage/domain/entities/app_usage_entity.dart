import 'package:equatable/equatable.dart';

/// Domain entity representing one app's usage for today.
///
/// How to use:
/// ```dart
/// final entity = AppUsageEntity(
///   packageName: 'com.instagram.android',
///   appName: 'Instagram',
///   todaySeconds: 120,
/// );
/// ```
class AppUsageEntity extends Equatable {
  /// Creates an immutable usage entity.
  const AppUsageEntity({
    required this.packageName,
    required this.appName,
    required this.todaySeconds,
    this.iconBytes,
  });

  final String packageName;
  final String appName;

  /// Cumulative seconds used today (across all sessions).
  final int todaySeconds;

  /// Optional PNG/JPEG bytes for the app icon when available.
  final List<int>? iconBytes;

  /// Returns a copy with selective overrides.
  ///
  /// Useful when the live ticker increments [todaySeconds].
  AppUsageEntity copyWith({
    String? packageName,
    String? appName,
    int? todaySeconds,
    List<int>? iconBytes,
  }) {
    return AppUsageEntity(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      todaySeconds: todaySeconds ?? this.todaySeconds,
      iconBytes: iconBytes ?? this.iconBytes,
    );
  }

  @override
  List<Object?> get props => [packageName, appName, todaySeconds, iconBytes];
}

/// Snapshot of permission + tracking status for the UI.
///
/// How to use in a bloc state:
/// ```dart
/// PermissionsStatus(hasUsageAccess: true, hasOverlayAccess: false);
/// ```
class PermissionsStatus extends Equatable {
  /// Creates a permission snapshot.
  const PermissionsStatus({
    required this.hasUsageAccess,
    required this.hasOverlayAccess,
  });

  final bool hasUsageAccess;
  final bool hasOverlayAccess;

  /// True when both Android special permissions are granted.
  bool get isReady => hasUsageAccess && hasOverlayAccess;

  @override
  List<Object?> get props => [hasUsageAccess, hasOverlayAccess];
}
