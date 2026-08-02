/// Pure helpers that turn Android usage events into calendar-day foreground
/// totals — the same approach Digital Wellbeing uses (not bucket aggregates).
///
/// How to use:
/// ```dart
/// final msByPackage = sumForegroundMsByPackage(
///   events: points,
///   rangeStartMs: startOfToday.millisecondsSinceEpoch,
///   rangeEndMs: DateTime.now().millisecondsSinceEpoch,
///   isIgnoredPackage: (pkg) => pkg == 'com.android.systemui',
/// );
/// final seconds = (msByPackage['org.telegram.messenger'] ?? 0) ~/ 1000;
/// ```
library;

/// One usage event used by [sumForegroundMsByPackage].
///
/// How to use: map each [EventUsageInfo] from the plugin into this DTO before
/// summing, so the math stays unit-testable without Android.
class UsageEventPoint {
  /// Creates a single chronological usage event.
  const UsageEventPoint({
    required this.packageName,
    required this.eventType,
    required this.timeStampMs,
  });

  /// Android package id that generated the event.
  final String packageName;

  /// Raw [UsageEvents.Event] type (e.g. 1 = resume, 2 / 23 = pause, 16 / 17 = idle).
  final int eventType;

  /// Epoch milliseconds when the event fired.
  final int timeStampMs;
}

/// ACTIVITY_RESUMED / MOVE_TO_FOREGROUND (1).
///
/// Note: type 15 is SCREEN_INTERACTIVE, not a resume — do not treat it as one.
bool isForegroundResumeEvent(int eventType) => eventType == 1;

/// ACTIVITY_PAUSED / MOVE_TO_BACKGROUND (2) and ACTIVITY_STOPPED (23).
///
/// Note: type 16 is SCREEN_NON_INTERACTIVE, not an activity pause.
bool isForegroundPauseEvent(int eventType) =>
    eventType == 2 || eventType == 23;

/// SCREEN_NON_INTERACTIVE (16) or KEYGUARD_SHOWN (17) — lock / screen-off.
///
/// How to use: close any open foreground session so lock/home never counts.
bool isScreenIdleEvent(int eventType) =>
    eventType == 16 || eventType == 17;

/// Sums foreground milliseconds per package inside [[rangeStartMs], [rangeEndMs]].
///
/// Events may begin *before* [rangeStartMs] so a session that crossed midnight
/// only contributes the portion after midnight (clipped), matching Digital
/// Wellbeing's "Today" window.
///
/// Useful when [queryAndAggregateUsageStats] would otherwise leak yesterday's
/// daily bucket into today's totals.
Map<String, int> sumForegroundMsByPackage({
  required List<UsageEventPoint> events,
  required int rangeStartMs,
  required int rangeEndMs,
  required bool Function(String packageName) isIgnoredPackage,
}) {
  // Guard inverted / empty ranges so callers never get negative totals.
  if (rangeEndMs <= rangeStartMs) return <String, int>{};

  // Chronological order is required to open/close sessions correctly.
  final sorted = List<UsageEventPoint>.from(events)
    ..sort((a, b) => a.timeStampMs.compareTo(b.timeStampMs));

  final totalsMs = <String, int>{};
  String? foregroundPackage;
  int? sessionStartMs;

  /// Adds the clipped [fromMs, toMs] slice into [totalsMs] for [packageName].
  void addClipped(String packageName, int fromMs, int toMs) {
    // Skip launcher / system UI / our own package — not "app usage".
    if (isIgnoredPackage(packageName)) return;

    final from = fromMs < rangeStartMs ? rangeStartMs : fromMs;
    final to = toMs > rangeEndMs ? rangeEndMs : toMs;
    // Entirely outside today's window (e.g. session closed before midnight).
    if (to <= from) return;
    if (to <= rangeStartMs) return;

    totalsMs[packageName] = (totalsMs[packageName] ?? 0) + (to - from);
  }

  for (final event in sorted) {
    final pkg = event.packageName;
    final time = event.timeStampMs;
    if (time <= 0) continue;

    // Lock screen / screen off — stop counting immediately.
    if (isScreenIdleEvent(event.eventType)) {
      final previousPackage = foregroundPackage;
      final previousStart = sessionStartMs;
      if (previousPackage != null && previousStart != null) {
        addClipped(previousPackage, previousStart, time);
      }
      foregroundPackage = null;
      sessionStartMs = null;
      continue;
    }

    if (pkg.isEmpty) continue;

    // App became visible — close any previous session first.
    if (isForegroundResumeEvent(event.eventType)) {
      final previousPackage = foregroundPackage;
      final previousStart = sessionStartMs;
      if (previousPackage != null && previousStart != null) {
        addClipped(previousPackage, previousStart, time);
      }
      // Home / system chrome: stop counting, do not open a new session.
      if (isIgnoredPackage(pkg)) {
        foregroundPackage = null;
        sessionStartMs = null;
      } else {
        foregroundPackage = pkg;
        sessionStartMs = time;
      }
      continue;
    }

    // App left the foreground — close only if it matches the open session.
    if (isForegroundPauseEvent(event.eventType)) {
      final openPackage = foregroundPackage;
      final openStart = sessionStartMs;
      if (openPackage == pkg && openPackage != null && openStart != null) {
        addClipped(openPackage, openStart, time);
        foregroundPackage = null;
        sessionStartMs = null;
      }
    }
  }

  // Still in an app at [rangeEndMs] (open session) — count until "now".
  final openPackage = foregroundPackage;
  final openStart = sessionStartMs;
  if (openPackage != null && openStart != null) {
    addClipped(openPackage, openStart, rangeEndMs);
  }

  return totalsMs;
}

/// Merges event-based seconds with the live SharedPreferences cache.
///
/// Events are the calendar-day source of truth. The live ticker may run a few
/// seconds ahead between syncs — keep cache only when it is *slightly* ahead.
/// A wildly higher cache is treated as stale (yesterday bleed) and discarded.
///
/// How to use:
/// ```dart
/// final seconds = mergeTodaySeconds(
///   eventSeconds: 90,
///   cachedSeconds: 95, // live ahead by 5s → keep 95
/// );
/// // cachedSeconds: 3000 with eventSeconds: 90 → returns 90 (stale cache)
/// ```
int mergeTodaySeconds({
  required int eventSeconds,
  required int cachedSeconds,
  int liveAheadGraceSeconds = 60,
}) {
  // Events already cover (or exceed) the cache — trust events.
  if (cachedSeconds <= eventSeconds) return eventSeconds;

  // Overlay ticked a few times since the last event snapshot — keep live.
  if (cachedSeconds - eventSeconds <= liveAheadGraceSeconds) {
    return cachedSeconds;
  }

  // Inflated / yesterday cache — do not let max() reintroduce bad totals.
  return eventSeconds;
}
