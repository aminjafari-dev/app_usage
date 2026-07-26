import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';

/// Base use case contract for domain operations.
///
/// How to use:
/// ```dart
/// class GetTodayUsageUseCase implements UseCase<List<AppUsageEntity>, NoParams> {
///   @override
///   Future<Either<Failure, List<AppUsageEntity>>> call(NoParams params) { ... }
/// }
/// ```
abstract class UseCase<Output, Params> {
  /// Executes the use case with [params].
  Future<Either<Failure, Output>> call(Params params);
}

/// Marker params when a use case needs no input.
class NoParams {
  /// Creates empty params.
  const NoParams();
}
