import 'package:equatable/equatable.dart';

import 'package:app_usage/features/app_usage/domain/entities/analytics_period.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// One chart bar: total foreground seconds for a local calendar day.
///
/// How to use: plot [totalSeconds] across [day] on the Analytics chart.
class DailyUsageBucket extends Equatable {
  /// Creates a single-day total.
  const DailyUsageBucket({
    required this.day,
    required this.totalSeconds,
  });

  /// Local midnight of the day this bucket covers.
  final DateTime day;

  /// Sum of all tracked apps' foreground time that day.
  final int totalSeconds;

  @override
  List<Object?> get props => [day, totalSeconds];
}

/// Aggregated usage for one [AnalyticsPeriod] ready for the UI.
///
/// How to use:
/// ```dart
/// final snapshot = await repository.getUsageForPeriod(AnalyticsPeriod.week);
/// ```
class PeriodUsageSnapshot extends Equatable {
  /// Creates an immutable period snapshot.
  const PeriodUsageSnapshot({
    required this.period,
    required this.apps,
    required this.dailyBuckets,
    required this.totalSeconds,
  });

  final AnalyticsPeriod period;

  /// Per-app totals for the whole period, sorted descending by seconds.
  final List<AppUsageEntity> apps;

  /// One entry per local calendar day in the period (oldest → newest).
  final List<DailyUsageBucket> dailyBuckets;

  /// Sum of all app seconds in the period.
  final int totalSeconds;

  /// Average seconds per calendar day in the period.
  int get averageSecondsPerDay {
    final days = period.dayCount;
    if (days <= 0) return 0;
    return totalSeconds ~/ days;
  }

  @override
  List<Object?> get props => [period, apps, dailyBuckets, totalSeconds];
}
