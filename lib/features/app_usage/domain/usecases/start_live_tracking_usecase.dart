import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Starts the live overlay counter and foreground polling.
///
/// How to use:
/// ```dart
/// await getIt<StartLiveTrackingUseCase>()(const NoParams());
/// ```
class StartLiveTrackingUseCase implements UseCase<Unit, NoParams> {
  /// Inject the repository via DI.
  StartLiveTrackingUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.startLiveTracking();
  }
}
