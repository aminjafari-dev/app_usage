import 'dart:async';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/utils/usage_time_calculator.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_local_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/usage_stats_data_source.dart';

/// Callback fired whenever the overlay badge should redraw or hide.
///
/// How to use inside [OverlayApp]:
/// ```dart
/// tracker.onTick = (payload) {
///   if (payload == null) {
///     // Home / launcher — hide the glassy badge.
///     setState(() => visible = false);
///     return;
///   }
///   setState(() { visible = true; /* apply payload */ });
/// };
/// ```
///
/// Pass `null` when the user is on the home screen (or any ignored package)
/// so the top badge is not shown while no trackable app is in use.
typedef OverlayTickCallback = void Function(OverlayTickPayload? payload);

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

  /// Poll while a trackable app is open (live second counter).
  static const _activePollInterval = Duration(seconds: 1);

  /// Poll while on home / lock screen — just enough to notice the next app.
  ///
  /// How to use: switched in automatically when [currentForegroundPackage]
  /// returns null so we do not hammer UsageStats on the wallpaper/keyguard.
  static const _idlePollInterval = Duration(seconds: 5);

  final UsageStatsDataSource _usageStats = UsageStatsDataSource();
  UsageLocalDataSource? _local;

  final Map<String, int> _todaySeconds = {};
  final Map<String, String> _appNames = {};

  /// Cached PackageManager icons (PNG) keyed by package name.
  ///
  /// How to use: resolve once per package via [UsageStatsDataSource.resolveIcon],
  /// then reuse on every tick so the badge shows Telegram/YouTube/etc. logos
  /// without shipping custom assets or re-fetching every second.
  final Map<String, List<int>?> _appIcons = {};

  Timer? _timer;
  String? _activePackage;
  String _cacheDate = todayDateKey();
  bool _running = false;
  bool _idle = true;
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
    // Main may finish writing prefs a moment after showOverlay — pick that up.
    await _mergeCachedTotals();

    _running = true;
    // Start in idle cadence; _onTickLoop upgrades to 1s only when an app is open.
    _armTimer(idle: true);
    await _onTickLoop();
  }

  /// Rebuilds the periodic timer for active (1s) vs idle (5s) modes.
  ///
  /// Useful so home/lock screens almost never query UsageStats, while an open
  /// app still gets a smooth second-by-second badge.
  void _armTimer({required bool idle}) {
    if (_timer != null && _idle == idle) return;
    _idle = idle;
    _timer?.cancel();
    final interval = idle ? _idlePollInterval : _activePollInterval;
    _timer = Timer.periodic(interval, (_) {
      unawaited(_onTickLoop());
    });
  }

  /// Merges a package→seconds map from the main isolate into the live counter.
  ///
  /// How to use: call when [OverlayDataSource.sendTodaySeed] arrives so the
  /// badge jumps from `00:00` to the real today total (never decreases).
  /// Example: seed Telegram `7200` while local has `3` → keep `7200`.
  void applySeedTotals(Map<dynamic, dynamic>? totals) {
    if (totals == null || totals.isEmpty) return;
    var raisedActive = false;
    for (final entry in totals.entries) {
      final package = entry.key.toString();
      final seconds = (entry.value as num?)?.toInt() ?? 0;
      if (package.isEmpty || seconds <= 0) continue;
      final current = _todaySeconds[package] ?? 0;
      // Never let a late seed shrink an already-running live total.
      if (seconds > current) {
        _todaySeconds[package] = seconds;
        if (package == _activePackage) raisedActive = true;
      }
    }
    // Repaint immediately when the foreground app's total was corrected.
    if (raisedActive) {
      final package = _activePackage;
      if (package == null) return;
      final seconds = _todaySeconds[package] ?? 0;
      _onTick?.call(
        OverlayTickPayload(
          packageName: package,
          appName: _appNames[package] ?? package,
          todaySeconds: seconds,
          iconBytes: _appIcons[package],
        ),
      );
      unawaited(_persistCache());
    }
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

    // Overlay isolate must reload — main may have just written today's totals.
    await local.reload();
    final aggregates = await _usageStats.queryTodayAggregates();
    final cached = await local.loadTodaySeconds();

    _todaySeconds.clear();
    _appNames.clear();
    _appIcons.clear();

    for (final model in aggregates) {
      final cachedSeconds = cached[model.packageName] ?? 0;
      // Events are the day source of truth; only keep a slightly-ahead live cache.
      // Useful so yesterday's inflated SharedPreferences cannot win via max().
      final seconds = mergeTodaySeconds(
        eventSeconds: model.todaySeconds,
        cachedSeconds: cachedSeconds,
      );
      _todaySeconds[model.packageName] = seconds;
      _appNames[model.packageName] = model.appName;
      // Seed logos from aggregates so the first badge paint already has them.
      _appIcons[model.packageName] = model.iconBytes;
    }

    // Keep packages that only exist in the live cache (rare but possible).
    // Critical on first run when event query in this isolate is empty/slow but
    // Home already persisted correct UsageStats totals to SharedPreferences.
    for (final entry in cached.entries) {
      if (_todaySeconds.containsKey(entry.key)) continue;
      _todaySeconds[entry.key] = entry.value;
      _appNames[entry.key] = await _usageStats.resolveAppName(entry.key);
      // Resolve the real launcher icon once for cache-only packages.
      _appIcons[entry.key] = await _usageStats.resolveIcon(entry.key);
    }

    // Persist corrected totals so a stale inflated cache is overwritten on disk.
    await _persistCache();
  }

  /// Reloads SharedPreferences and lifts any package totals that are ahead.
  ///
  /// Useful right after overlay start when Home saved seed data a few hundred
  /// ms later than this isolate's first hydrate.
  Future<void> _mergeCachedTotals() async {
    final local = _local;
    if (local == null) return;
    try {
      await local.reload();
      final cached = await local.loadTodaySeconds();
      for (final entry in cached.entries) {
        final current = _todaySeconds[entry.key] ?? 0;
        if (entry.value > current) {
          _todaySeconds[entry.key] = entry.value;
        }
      }
    } catch (_) {
      // Prefs reload failures should not block the ticker.
    }
  }

  /// Ensures [package] has a seeded today total before the first +1 tick.
  ///
  /// How to use: on app switch when the package is missing from memory so we
  /// never fall back to `putIfAbsent(..., 0)` while Home already knows 2h.
  Future<void> _ensurePackageSeeded(String package) async {
    if ((_todaySeconds[package] ?? 0) > 0) return;

    await _mergeCachedTotals();
    if ((_todaySeconds[package] ?? 0) > 0) return;

    try {
      final aggregates = await _usageStats.queryTodayAggregates();
      for (final model in aggregates) {
        final current = _todaySeconds[model.packageName] ?? 0;
        if (model.todaySeconds > current) {
          _todaySeconds[model.packageName] = model.todaySeconds;
          _appNames[model.packageName] = model.appName;
          _appIcons[model.packageName] = model.iconBytes;
        }
      }
    } catch (_) {
      // Foreground detection can continue even if a re-seed query fails.
    }
  }

  /// Poll loop: detect foreground app, increment, persist, update badge.
  ///
  /// On home / lock screen this returns quickly after a null package check and
  /// stays on the slow idle timer — no increment, persist, or shareData.
  Future<void> _onTickLoop() async {
    if (!_running) return;
    try {
      await _rollDayIfNeeded();

      // Pass last active package so we keep counting after UsageStats event gaps.
      // Never pass a package while already idle — lock/home must stay quiet.
      final package = await _usageStats.currentForegroundPackage(
        keepIfNoEvent: _activePackage,
      );

      // Launcher / home / lock / our own app: do nothing (hide badge + slow poll).
      // Example: press Home or lock → badge gone, UsageStats barely queried.
      if (package == null) {
        if (_activePackage != null) {
          _activePackage = null;
          _onTick?.call(null);
        }
        _armTimer(idle: true);
        return;
      }

      // A real app is open — run the live 1s counter.
      _armTimer(idle: false);

      // App switch: resolve label + PackageManager icon once, then increment.
      // Useful so switching Telegram → YouTube swaps both name and real logo.
      final switched = package != _activePackage;
      if (switched) {
        _activePackage = package;
        if (!_appNames.containsKey(package)) {
          _appNames[package] = await _usageStats.resolveAppName(package);
        }
        // Fetch the installed app's launcher icon (not a custom PNG asset).
        // Retry when a previous resolve returned null (PackageManager miss).
        if (_appIcons[package] == null) {
          _appIcons[package] = await _usageStats.resolveIcon(package);
        }
        // Prefer prefs / UsageStats over starting a known app at zero.
        await _ensurePackageSeeded(package);
        _todaySeconds.putIfAbsent(package, () => 0);
      }

      final next = (_todaySeconds[package] ?? 0) + 1;
      _todaySeconds[package] = next;

      final payload = OverlayTickPayload(
        packageName: package,
        appName: _appNames[package] ?? package,
        todaySeconds: next,
        iconBytes: _appIcons[package],
      );

      // Drive the overlay UI in this isolate (works even if main is dead).
      _onTick?.call(payload);

      // Persist so the main app can rebuild today's list after a cold start.
      await _persistCache();

      // Notify the main isolate when it is alive (Home preview / list sync).
      // shareData is a no-op on the receiver side if nobody is listening.
      // Only include icon bytes on app switch to keep the IPC light.
      try {
        await FlutterOverlayWindow.shareData({
          ...payload.toMap(includeIcon: switched),
          'totals': _todaySeconds,
        });
      } catch (_) {
        // Main isolate may be gone; badge already updated locally.
      }
    } catch (_) {
      // Tick failures should not crash the overlay; next interval retries.
    }
  }

  Future<void> _persistCache() async {
    final local = _local;
    if (local == null) return;
    // Merge with disk so a partial overlay map cannot wipe Home's seed
    // (e.g. Telegram 7200) before this isolate finishes hydrating.
    try {
      await local.reload();
      final existing = await local.loadTodaySeconds();
      final merged = Map<String, int>.from(existing);
      for (final entry in _todaySeconds.entries) {
        final previous = merged[entry.key] ?? 0;
        if (entry.value > previous) {
          merged[entry.key] = entry.value;
        }
      }
      for (final entry in merged.entries) {
        final current = _todaySeconds[entry.key] ?? 0;
        if (entry.value > current) {
          _todaySeconds[entry.key] = entry.value;
        }
      }
      await local.saveTodaySeconds(merged);
    } catch (_) {
      await local.saveTodaySeconds(Map<String, int>.from(_todaySeconds));
    }
  }

  Future<void> _rollDayIfNeeded() async {
    final today = todayDateKey();
    // At local midnight, wipe totals and re-seed from UsageStats.
    if (today != _cacheDate) {
      _cacheDate = today;
      _todaySeconds.clear();
      _appNames.clear();
      _appIcons.clear();
      _activePackage = null;
      final local = _local;
      if (local != null) {
        await local.reload();
        await local.loadTodaySeconds();
      }
      final aggregates = await _usageStats.queryTodayAggregates();
      for (final model in aggregates) {
        _todaySeconds[model.packageName] = model.todaySeconds;
        _appNames[model.packageName] = model.appName;
        // Keep real launcher logos after the midnight reset.
        _appIcons[model.packageName] = model.iconBytes;
      }
    }
  }
}
