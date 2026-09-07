import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/features/app_usage/domain/entities/analytics_period.dart';
import 'package:app_usage/features/app_usage/domain/entities/period_usage_snapshot.dart';
import 'package:app_usage/features/app_usage/domain/usecases/get_period_usage_usecase.dart';

/// Loads Analytics snapshots when the user picks a period.
///
/// How to use:
/// ```dart
/// BlocProvider(
///   create: (_) => locator<AnalyticsCubit>()..load(),
///   child: const AnalyticsPage(),
/// );
/// ```
class AnalyticsCubit extends Cubit<AnalyticsState> {
  /// Injects the period-usage use case.
  AnalyticsCubit(this._getPeriodUsage) : super(const AnalyticsState());

  final GetPeriodUsageUseCase _getPeriodUsage;

  /// Loads [period] (defaults to the current selection).
  Future<void> load([AnalyticsPeriod? period]) async {
    final next = period ?? state.period;
    emit(
      state.copyWith(
        period: next,
        status: AnalyticsStatus.loading,
        clearError: true,
      ),
    );

    final result = await _getPeriodUsage(GetPeriodUsageParams(next));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (snapshot) => emit(
        state.copyWith(
          status: AnalyticsStatus.loaded,
          snapshot: snapshot,
          clearError: true,
        ),
      ),
    );
  }

  /// Switches the selected period and reloads.
  Future<void> selectPeriod(AnalyticsPeriod period) {
    if (period == state.period && state.status == AnalyticsStatus.loaded) {
      return Future.value();
    }
    return load(period);
  }
}

/// UI status for the Analytics tab.
enum AnalyticsStatus { initial, loading, loaded, error }

/// Immutable state for [AnalyticsCubit].
class AnalyticsState extends Equatable {
  /// Creates Analytics UI state.
  const AnalyticsState({
    this.period = AnalyticsPeriod.week,
    this.status = AnalyticsStatus.initial,
    this.snapshot,
    this.errorMessage,
  });

  final AnalyticsPeriod period;
  final AnalyticsStatus status;
  final PeriodUsageSnapshot? snapshot;
  final String? errorMessage;

  /// Returns a copy with selective overrides.
  AnalyticsState copyWith({
    AnalyticsPeriod? period,
    AnalyticsStatus? status,
    PeriodUsageSnapshot? snapshot,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AnalyticsState(
      period: period ?? this.period,
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [period, status, snapshot, errorMessage];
}
