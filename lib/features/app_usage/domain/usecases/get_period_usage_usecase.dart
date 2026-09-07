import 'package:dartz/dartz.dart';

import 'package:app_usage/core/error/failures.dart';
import 'package:app_usage/core/usecase/usecase.dart';
import 'package:app_usage/features/app_usage/domain/entities/analytics_period.dart';
import 'package:app_usage/features/app_usage/domain/entities/period_usage_snapshot.dart';
import 'package:app_usage/features/app_usage/domain/repositories/app_usage_repository.dart';

/// Loads per-app + daily usage for a selected Analytics period.
///
/// How to use:
/// ```dart
/// final result = await getIt<GetPeriodUsageUseCase>()(
///   const GetPeriodUsageParams(AnalyticsPeriod.week),
/// );
/// ```
class GetPeriodUsageUseCase
    implements UseCase<PeriodUsageSnapshot, GetPeriodUsageParams> {
  /// Inject the repository via DI.
  GetPeriodUsageUseCase(this._repository);

  final AppUsageRepository _repository;

  @override
  Future<Either<Failure, PeriodUsageSnapshot>> call(
    GetPeriodUsageParams params,
  ) {
    return _repository.getUsageForPeriod(params.period);
  }
}

/// Params for [GetPeriodUsageUseCase].
class GetPeriodUsageParams {
  /// Creates params for one [AnalyticsPeriod].
  const GetPeriodUsageParams(this.period);

  final AnalyticsPeriod period;
}
