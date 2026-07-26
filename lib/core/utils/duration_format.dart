/// Formats cumulative seconds for the glassy counter and lists.
///
/// How to use:
/// ```dart
/// formatUsageDuration(75); // "01:15"
/// formatUsageDuration(3661); // "1:01:01"
/// ```
String formatUsageDuration(int totalSeconds) {
  // Guard against negative values from bad cache merges.
  final seconds = totalSeconds < 0 ? 0 : totalSeconds;
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;

  // Under one hour keep the compact mm:ss form used on the overlay pill.
  if (h == 0) {
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Returns a local calendar date key like `2026-07-26` for cache buckets.
///
/// Useful when resetting today's totals at midnight.
String todayDateKey([DateTime? now]) {
  final d = now ?? DateTime.now();
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$month-$day';
}

/// Start of the local day for UsageStats queries.
DateTime startOfToday([DateTime? now]) {
  final d = now ?? DateTime.now();
  return DateTime(d.year, d.month, d.day);
}
