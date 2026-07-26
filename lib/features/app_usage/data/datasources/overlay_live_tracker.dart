import 'dart:async';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_local_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_stats_data_source.dart';

/// Callback fired whenever the overlay badge should redraw.
///
/// How to use inside [OverlayApp]:
/// ```dart
/// tracker.onTick = (payload) => setState(() { ... });
/// ```
typedef OverlayTickCallback = void Function(OverlayTickPayload payload);

/// Runs the 1-second usage counter **inside the overlay isolate**.
///
/// Why this exists: the main Flutter isolate dies when the user swipes the app
/// away or Android kills the activity. The overlay foreground service keeps
/// its own Dart isolate alive, so polling here keeps the glassy badge growing
/// even while the host app is backgrounded or "killed" from Recents.
///
/// How to use:
/// ```dart
/// final tracker = OverlayLiveTracker();
/// await tracker.start(onTick: (p) => setState(() => ...));
/// // later
/// await tracker.dispose();
/// ```
class OverlayLiveTracker {
  /// Creates a tracker; call [start] after the overlay widget mounts.
  OverlayLiveTracker();

  final UsageStatsDataSource _usageStats = UsageStatsDataSource();
  UsageLocalDataSource? _local;

  final Map<String, int> _todaySeconds = {};
  final Map<String, String> _appNames = {};

  Timer? _timer;
  String? _activePackage;
  String _cacheDate = todayDateKey();
  bool _running = false;
  OverlayTickCallback? _onTick;

  /// Whether the 1s loop is currently active in this overlay isolate.
  bool get isRunning => _running;

  /// Boots SharedPreferences, seeds today's totals, then starts the ticker.
  ///
  /// Useful right after [OverlayApp] mounts so the badge shows a real total
  /// immediately (not `00:00`) for whichever app is already open.
  Future<void> start({required OverlayTickCallback onTick}) async {
    // Idempotent: overlay rebuilds must not stack multiple timers.
    if (_running) return;

    _onTick = onTick;
    final prefs = await SharedPreferences.getInstance();
    _local = UsageLocalDataSource(prefs);

    await _hydrateToday();
    _running = true;
    _timer?.cancel();
    // One-second cadence matches the old main-isolate tracker UX.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_onTickLoop());
    });
    await _onTickLoop();
  }

  /// Cancels the timer and drops listeners. Call from [State.dispose].
  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _onTick = null;
  }

  /// Seeds in-memory maps from UsageStats + SharedPreferences (max per package).
  Future<void> _hydrateToday() async {
    await _rollDayIfNeeded();
    final local = _local;
    if (local == null) return;

    final aggregates = await _usageStats.queryTodayAggregates();
    final cached = await local.loadTodaySeconds();

    _todaySeconds.clear();
    _appNames.clear();

    for (final model in aggregates) {
      final cachedSeconds = cached[model.packageName] ?? 0;
      // Prefer the larger value so we never lose live-ticker progress.
      final seconds = model.todaySeconds > cachedSeconds
          ? model.todaySeconds
          : cachedSeconds;
      _todaySeconds[model.packageName] = seconds;
      _appNames[model.packageName] = model.appName;
    }

    // Keep packages that only exist in the live cache (rare but possible).
    for (final entry in cached.entries) {
      if (_todaySeconds.containsKey(entry.key)) continue;
      _todaySeconds[entry.key] = entry.value;
      _appNames[entry.key] = await _usageStats.resolveAppName(entry.key);
    }
  }

  /// One-second loop: detect foreground app, increment, persist, update badge.
  Future<void> _onTickLoop() async {
    if (!_running) return;
    try {
      await _rollDayIfNeeded();

      // Pass last active package so we keep counting after UsageStats event gaps.
      final package = await _usageStats.currentForegroundPackage(
        keepIfNoEvent: _activePackage,
      );

      // Launcher / our own app: pause counting; leave last badge text as-is.
      if (package == null) {
        _activePackage = null;
        return;
      }

      // App switch: resolve a friendly label once, then start incrementing.
      if (package != _activePackage) {
        _activePackage = package;
        if (!_appNames.containsKey(package)) {
          _appNames[package] = await _usageStats.resolveAppName(package);
        }
        _todaySeconds.putIfAbsent(package, () => 0);
      }

      final next = (_todaySeconds[package] ?? 0) + 1;
      _todaySeconds[package] = next;

      final payload = OverlayTickPayload(
        packageName: package,
        appName: _appNames[package] ?? package,
        todaySeconds: next,
      );

      // Drive the overlay UI in this isolate (works even if main is dead).
      _onTick?.call(payload);

      // Persist so the main app can rebuild today's list after a cold start.
      await _persistCache();

      // Notify the main isolate when it is alive (Home preview / list sync).
      // shareData is a no-op on the receiver side if nobody is listening.
      try {
        await FlutterOverlayWindow.shareData({
          ...payload.toMap(),
          'totals': _todaySeconds,
        });
      } catch (_) {
        // Main isolate may be gone; badge already updated locally.
      }
    } catch (_) {
      // Tick failures should not crash the overlay; next second retries.
    }
  }

  Future<void> _persistCache() async {
    final local = _local;
    if (local == null) return;
    await local.saveTodaySeconds(Map<String, int>.from(_todaySeconds));
  }

  Future<void> _rollDayIfNeeded() async {
    final today = todayDateKey();
    // At local midnight, wipe totals and re-seed from UsageStats.
    if (today != _cacheDate) {
      _cacheDate = today;
      _todaySeconds.clear();
      _appNames.clear();
      _activePackage = null;
      final local = _local;
      if (local != null) {
        await local.loadTodaySeconds();
      }
      final aggregates = await _usageStats.queryTodayAggregates();
      for (final model in aggregates) {
        _todaySeconds[model.packageName] = model.todaySeconds;
        _appNames[model.packageName] = model.appName;
      }
    }
  }
}
