import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Opens Android Usage Access settings for the user.
///
/// How to use:
/// ```dart
/// await getIt<RequestUsagePermissionUseCase>()(const NoParams());
/// ```
class RequestUsagePermissionUseCase implements UseCase<Unit, NoParams> {
  /// Inject the repository via DI.
  RequestUsagePermissionUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.requestUsagePermission();
  }
}
