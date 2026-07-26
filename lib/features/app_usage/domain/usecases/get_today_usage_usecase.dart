import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Loads today's per-app usage totals.
///
/// How to use:
/// ```dart
/// final result = await getIt<GetTodayUsageUseCase>()(const NoParams());
/// ```
class GetTodayUsageUseCase
    implements UseCase<List<AppUsageEntity>, NoParams> {
  /// Inject the repository via DI.
  GetTodayUsageUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, List<AppUsageEntity>>> call(NoParams params) {
    return _repository.getTodayUsage();
  }
}
