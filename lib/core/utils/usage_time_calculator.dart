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

  /// Raw [UsageEvents.Event] type (e.g. 1 = resume, 2 = pause, 16 / 17 = idle).
  final int eventType;

  /// Epoch milliseconds when the event fired.
  final int timeStampMs;
}

/// ACTIVITY_RESUMED / MOVE_TO_FOREGROUND (1).
///
/// Note: type 15 is SCREEN_INTERACTIVE, not a resume — do not treat it as one.
bool isForegroundResumeEvent(int eventType) => eventType == 1;

/// ACTIVITY_PAUSED / MOVE_TO_BACKGROUND (2) — the only event that ends a session.
///
/// Note: type 16 is SCREEN_NON_INTERACTIVE, not an activity pause.
bool isForegroundPauseEvent(int eventType) => eventType == 2;

/// ACTIVITY_STOPPED (23) — bookkeeping only, never ends a foreground session.
///
/// Android reports lifecycle per *activity*, not per app. Moving between
/// screens inside one app logs `A paused → B resumed → A stopped`, so the stop
/// arrives while the app is still on screen. Treating it as a pause would end
/// the session of an app the user never left (back press, opening a story).
bool isActivityStoppedEvent(int eventType) => eventType == 23;

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
/// Pass [isTransientSystemPackage] so system chrome drawn over an app (shade,
/// volume panel) does not truncate that app's running session.
Map<String, int> sumForegroundMsByPackage({
  required List<UsageEventPoint> events,
  required int rangeStartMs,
  required int rangeEndMs,
  required bool Function(String packageName) isIgnoredPackage,
  bool Function(String packageName)? isTransientSystemPackage,
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
      // Shade / volume panel over a running app: leave the session untouched.
      if (isTransientSystemPackage?.call(pkg) ?? false) continue;
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

    // A stop for an app whose session is still open belongs to an activity that
    // already paused earlier, so it must not shorten the running session.
    if (isActivityStoppedEvent(event.eventType)) continue;

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

/// Decides which app is on screen right now by replaying [events].
///
/// Android only logs an event when something *changes*, so staying inside one
/// app produces silence. [seedPackage] carries the previously detected app into
/// the replay: without it, a window whose opening resume has already scrolled
/// out would wrongly report "no app open".
///
/// - Resume of a real app → that package
/// - Resume of a launcher / our own app ([isIdlePackage]) → `null`
/// - Resume of system chrome ([isTransientSystemPackage]) → unchanged; the
///   notification shade or volume panel draws *over* the app being used
/// - Lock / screen off → `null`
/// - Pause of the open app → `null`, but only after [pauseGraceMs], because an
///   in-app screen change pauses one activity a beat before the next resumes
///
/// How to use:
/// ```dart
/// final pkg = resolveForegroundPackage(
///   events: points,
///   nowMs: DateTime.now().millisecondsSinceEpoch,
///   seedPackage: lastActivePackage,
///   isIdlePackage: (p) => p.contains('launcher'),
///   isTransientSystemPackage: (p) => p == 'com.android.systemui',
/// );
/// ```
String? resolveForegroundPackage({
  required List<UsageEventPoint> events,
  required int nowMs,
  required bool Function(String packageName) isIdlePackage,
  required bool Function(String packageName) isTransientSystemPackage,
  String? seedPackage,
  int pauseGraceMs = 1500,
}) {
  final sorted = List<UsageEventPoint>.from(events)
    ..sort((a, b) => a.timeStampMs.compareTo(b.timeStampMs));

  String? foreground = seedPackage;
  int? pendingPauseMs;

  for (final event in sorted) {
    final pkg = event.packageName;

    // Lock screen or display off → idle; never count over the keyguard.
    if (isScreenIdleEvent(event.eventType)) {
      foreground = null;
      pendingPauseMs = null;
      continue;
    }

    if (isForegroundResumeEvent(event.eventType)) {
      if (pkg.isEmpty) continue;
      // Shade / volume / recents chrome: the app underneath is still in use.
      if (isTransientSystemPackage(pkg)) continue;
      foreground = isIdlePackage(pkg) ? null : pkg;
      pendingPauseMs = null;
      continue;
    }

    // Stops arrive after the next activity of the same app resumed — ignore.
    if (isActivityStoppedEvent(event.eventType)) continue;

    if (isForegroundPauseEvent(event.eventType)) {
      if (foreground == null) continue;
      // Matching pause (or empty OEM pause) may close the open session.
      if (pkg.isEmpty || pkg == foreground) {
        pendingPauseMs = event.timeStampMs;
      }
    }
  }

  final pausedAt = pendingPauseMs;
  if (pausedAt == null) return foreground;
  // The replacement resume may still be in flight — hold the current app.
  if (nowMs - pausedAt < pauseGraceMs) return foreground;
  return null;
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
