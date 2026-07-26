import 'package:equatable/equatable.dart';

/// Base failure used with dartz Either across domain and data layers.
///
/// How to use:
/// ```dart
/// return Left(ServerFailure('Could not load usage'));
/// ```
abstract class Failure extends Equatable {
  /// Creates a failure with a user-facing [message].
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure when Android usage/overlay APIs throw.
class PlatformFailure extends Failure {
  /// Example: UsageStatsManager query failed.
  const PlatformFailure([super.message = 'Platform error']);
}

/// Failure when local cache read/write fails.
class CacheFailure extends Failure {
  /// Example: SharedPreferences unavailable.
  const CacheFailure([super.message = 'Cache error']);
}

/// Failure when a required permission is missing.
class PermissionFailure extends Failure {
  /// Example: overlay permission not granted.
  const PermissionFailure([super.message = 'Permission required']);
}

/// Failure for unexpected errors.
class UnexpectedFailure extends Failure {
  /// Example: unknown exception bubbled up from a repository.
  const UnexpectedFailure([super.message = 'Unexpected error']);
}
