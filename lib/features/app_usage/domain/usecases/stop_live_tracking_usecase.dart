import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Stops live tracking and hides the floating overlay.
///
/// How to use:
/// ```dart
/// await getIt<StopLiveTrackingUseCase>()(const NoParams());
/// ```
class StopLiveTrackingUseCase implements UseCase<Unit, NoParams> {
  /// Inject the repository via DI.
  StopLiveTrackingUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.stopLiveTracking();
  }
}
