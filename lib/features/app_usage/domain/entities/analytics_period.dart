/// Selectable window for the Analytics tab.
///
/// How to use:
/// ```dart
/// final range = AnalyticsPeriod.week.rangeEndingAt(DateTime.now());
/// ```
///
/// Android UsageStats history is typically limited to about 10 days on many
/// devices, so the longest option is [tenDays].
enum AnalyticsPeriod {
  /// Last 3 local calendar days including today.
  threeDays,

  /// Last 7 local calendar days including today.
  week,

  /// Last 10 local calendar days including today (device history limit).
  tenDays,
}

/// Inclusive local-day range for an [AnalyticsPeriod].
class AnalyticsDateRange {
  /// Creates a half-open style window: [start] inclusive, [end] exclusive-ish
  /// for day math (queries still use [end] as "now" when it is today).
  const AnalyticsDateRange({
    required this.start,
    required this.end,
  });

  /// Start of the first local day in the period.
  final DateTime start;

  /// Exclusive end of the last partial day (typically [DateTime.now]).
  final DateTime end;
}

extension AnalyticsPeriodX on AnalyticsPeriod {
  /// How many local calendar days this period covers (including today).
  int get dayCount => switch (this) {
        AnalyticsPeriod.threeDays => 3,
        AnalyticsPeriod.week => 7,
        AnalyticsPeriod.tenDays => 10,
      };

  /// Local midnight of the first day → [now] for this period.
  AnalyticsDateRange rangeEndingAt(DateTime now) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final start = todayStart.subtract(Duration(days: dayCount - 1));
    return AnalyticsDateRange(start: start, end: now);
  }
}
