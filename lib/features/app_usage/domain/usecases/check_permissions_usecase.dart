import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Checks usage-access and overlay permissions.
///
/// How to use:
/// ```dart
/// final status = await getIt<CheckPermissionsUseCase>()(const NoParams());
/// ```
class CheckPermissionsUseCase
    implements UseCase<PermissionsStatus, NoParams> {
  /// Inject the repository via DI.
  CheckPermissionsUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, PermissionsStatus>> call(NoParams params) {
    return _repository.checkPermissions();
  }
}
