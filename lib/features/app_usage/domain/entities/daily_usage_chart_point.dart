/// One bar on the Analytics usage chart.
///
/// How to use: built from [DailyUsageBucket]s (one bar per local day).
class UsageChartPoint {
  /// Creates a labeled chart bar.
  const UsageChartPoint({
    required this.labelDay,
    required this.totalSeconds,
  });

  /// Day used for the axis label.
  final DateTime labelDay;

  /// Foreground seconds represented by this bar.
  final int totalSeconds;
}
