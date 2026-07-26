import 'package:equatable/equatable.dart';

import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Permission-check operation state.
///
/// How to use with pattern matching:
/// ```dart
/// switch (state.permissions) {
///   case PermissionsOpCompleted(:final status): ...
///   default: ...
/// }
/// ```
sealed class PermissionsOpState extends Equatable {
  const PermissionsOpState();

  const factory PermissionsOpState.initial() = PermissionsOpInitial;
  const factory PermissionsOpState.loading() = PermissionsOpLoading;
  const factory PermissionsOpState.completed(PermissionsStatus status) =
      PermissionsOpCompleted;
  const factory PermissionsOpState.error(String message) = PermissionsOpError;
}

class PermissionsOpInitial extends PermissionsOpState {
  const PermissionsOpInitial();

  @override
  List<Object?> get props => [];
}

class PermissionsOpLoading extends PermissionsOpState {
  const PermissionsOpLoading();

  @override
  List<Object?> get props => [];
}

class PermissionsOpCompleted extends PermissionsOpState {
  const PermissionsOpCompleted(this.status);

  final PermissionsStatus status;

  @override
  List<Object?> get props => [status];
}

class PermissionsOpError extends PermissionsOpState {
  const PermissionsOpError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Today's usage list operation state.
sealed class TodayUsageOpState extends Equatable {
  const TodayUsageOpState();

  const factory TodayUsageOpState.initial() = TodayUsageOpInitial;
  const factory TodayUsageOpState.loading() = TodayUsageOpLoading;
  const factory TodayUsageOpState.completed(List<AppUsageEntity> apps) =
      TodayUsageOpCompleted;
  const factory TodayUsageOpState.error(String message) = TodayUsageOpError;
}

class TodayUsageOpInitial extends TodayUsageOpState {
  const TodayUsageOpInitial();

  @override
  List<Object?> get props => [];
}

class TodayUsageOpLoading extends TodayUsageOpState {
  const TodayUsageOpLoading();

  @override
  List<Object?> get props => [];
}

class TodayUsageOpCompleted extends TodayUsageOpState {
  const TodayUsageOpCompleted(this.apps);

  final List<AppUsageEntity> apps;

  @override
  List<Object?> get props => [apps];
}

class TodayUsageOpError extends TodayUsageOpState {
  const TodayUsageOpError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Start/stop tracking operation state.
sealed class TrackingOpState extends Equatable {
  const TrackingOpState();

  const factory TrackingOpState.initial() = TrackingOpInitial;
  const factory TrackingOpState.loading() = TrackingOpLoading;
  const factory TrackingOpState.completed({required bool isTracking}) =
      TrackingOpCompleted;
  const factory TrackingOpState.error(String message) = TrackingOpError;
}

class TrackingOpInitial extends TrackingOpState {
  const TrackingOpInitial();

  @override
  List<Object?> get props => [];
}

class TrackingOpLoading extends TrackingOpState {
  const TrackingOpLoading();

  @override
  List<Object?> get props => [];
}

class TrackingOpCompleted extends TrackingOpState {
  const TrackingOpCompleted({required this.isTracking});

  final bool isTracking;

  @override
  List<Object?> get props => [isTracking];
}

class TrackingOpError extends TrackingOpState {
  const TrackingOpError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Main [UsageBloc] state combining all operation slices.
///
/// How to use:
/// ```dart
/// BlocBuilder<UsageBloc, UsageState>(...)
/// ```
class UsageState extends Equatable {
  /// Creates the combined usage UI state.
  const UsageState({
    required this.permissions,
    required this.todayUsage,
    required this.tracking,
    this.currentApp,
  });

  /// Initial empty state for the bloc constructor.
  factory UsageState.initial() => const UsageState(
        permissions: PermissionsOpState.initial(),
        todayUsage: TodayUsageOpState.initial(),
        tracking: TrackingOpState.initial(),
        currentApp: null,
      );

  final PermissionsOpState permissions;
  final TodayUsageOpState todayUsage;
  final TrackingOpState tracking;
  final AppUsageEntity? currentApp;

  /// Returns a copy updating only the provided fields.
  UsageState copyWith({
    PermissionsOpState? permissions,
    TodayUsageOpState? todayUsage,
    TrackingOpState? tracking,
    AppUsageEntity? currentApp,
    bool clearCurrentApp = false,
  }) {
    return UsageState(
      permissions: permissions ?? this.permissions,
      todayUsage: todayUsage ?? this.todayUsage,
      tracking: tracking ?? this.tracking,
      currentApp: clearCurrentApp ? null : (currentApp ?? this.currentApp),
    );
  }

  @override
  List<Object?> get props => [permissions, todayUsage, tracking, currentApp];
}
