import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Starts the top live counter automatically when permissions allow it.
///
/// How to use:
/// ```dart
/// await getIt<EnsureAutoTrackingUseCase>()(const NoParams());
/// ```
///
/// Useful after Home opens or after returning from Android settings so the
/// glassy pill appears as soon as the user opens another app.
class EnsureAutoTrackingUseCase implements UseCase<Unit, NoParams> {
  /// Inject the repository via DI.
  EnsureAutoTrackingUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.ensureAutoTrackingStarted();
  }
}
