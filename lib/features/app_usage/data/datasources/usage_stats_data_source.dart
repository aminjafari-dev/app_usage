import 'dart:typed_data';

import 'package:usage_stats/usage_stats.dart';

import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/utils/usage_time_calculator.dart';

/// Raw DTO for one app's usage pulled from Android UsageStatsManager.
///
/// How to use inside data sources only — map to [AppUsageEntity] in the repository.
class UsageInfoModel {
  /// Creates a usage model from Android package stats.
  const UsageInfoModel({
    required this.packageName,
    required this.appName,
    required this.todaySeconds,
    this.iconBytes,
  });

  final String packageName;
  final String appName;
  final int todaySeconds;
  final Uint8List? iconBytes;
}

/// Talks to the `usage_stats` plugin for permissions, events, and aggregates.
///
/// How to use:
/// ```dart
/// final ds = UsageStatsDataSource();
/// final granted = await ds.hasUsagePermission();
/// ```
class UsageStatsDataSource {
  /// Package id of this app so we can ignore our own foreground events.
  static const ownPackageName = 'com.example.app_usage';

  /// Common launcher / lock-screen / system packages to skip for live counting.
  static const _ignoredPackages = <String>{
    ownPackageName,
    'android',
    'com.android.systemui',
    'com.android.keyguard',
    'com.google.android.apps.nexuslauncher',
    'com.android.launcher',
    'com.android.launcher3',
    'com.miui.home',
    'com.mi.android.globallauncher',
    'com.sec.android.app.launcher',
    'com.huawei.android.launcher',
    'com.oppo.launcher',
    'com.bbk.launcher2',
    'com.realme.launcher',
    'com.nothing.launcher',
    'com.microsoft.launcher',
    'com.teslacoilsw.launcher',
    'com.actionlauncher.playstore',
  };

  /// Returns whether PACKAGE_USAGE_STATS is granted.
  Future<bool> hasUsagePermission() async {
    return await UsageStats.checkUsagePermission() ?? false;
  }

  /// Opens the system Usage Access settings screen.
  Future<void> requestUsagePermission() async {
    await UsageStats.grantUsagePermission();
  }

  /// Seeds today's totals from foreground **events** (not daily bucket aggregates).
  ///
  /// Why events: [UsageStats.queryAndAggregateUsageStats] expands the query to
  /// whole Android intervals and often leaks yesterday into "Today" — especially
  /// right after midnight. Digital Wellbeing-style math uses resume/pause pairs
  /// clipped to local midnight → now instead.
  ///
  /// How to use: call at tracking start / Home refresh so the list matches the
  /// system Digital Wellbeing day window.
  ///
  /// Example: Telegram open 10 min yesterday + 30 s today → returns ~30, not 630.
  Future<List<UsageInfoModel>> queryTodayAggregates() async {
    final end = DateTime.now();
    final start = startOfToday(end);
    // Look back before midnight so a session that crossed 00:00 is detected and
    // then clipped — only the post-midnight slice counts toward today.
    final lookback = start.subtract(const Duration(hours: 6));
    final rawEvents = await UsageStats.queryEvents(lookback, end);

    final points = <UsageEventPoint>[];
    for (final event in rawEvents) {
      final pkg = event.packageName;
      final type = event.eventTypeValue;
      final time = int.tryParse(event.timeStamp ?? '') ?? 0;
      // Drop malformed plugin rows before the pure calculator runs.
      if (pkg == null || pkg.isEmpty || type == null || time <= 0) continue;
      points.add(
        UsageEventPoint(
          packageName: pkg,
          eventType: type,
          timeStampMs: time,
        ),
      );
    }

    final msByPackage = sumForegroundMsByPackage(
      events: points,
      rangeStartMs: start.millisecondsSinceEpoch,
      rangeEndMs: end.millisecondsSinceEpoch,
      isIgnoredPackage: _isIgnoredPackage,
    );

    final results = <UsageInfoModel>[];
    for (final entry in msByPackage.entries) {
      final packageName = entry.key;
      final seconds = entry.value ~/ 1000;
      // Skip apps with no meaningful foreground time today.
      if (seconds <= 0) continue;

      final appName = await resolveAppName(packageName);
      final icon = await resolveIcon(packageName);
      results.add(
        UsageInfoModel(
          packageName: packageName,
          appName: appName,
          todaySeconds: seconds,
          iconBytes: icon,
        ),
      );
    }
    return results;
  }

  /// Detects the current foreground package from recent usage events.
  ///
  /// Android only emits ACTIVITY_RESUMED when an app becomes foreground — not
  /// every second while it stays open. So after a short idle window there are
  /// no new events. Lock screen / screen-off must clear the active app even
  /// when the previous resume is still the newest type-1 event.
  ///
  /// How to use:
  /// ```dart
  /// final pkg = await ds.currentForegroundPackage(
  ///   keepIfNoEvent: lastActivePackage,
  /// );
  /// ```
  ///
  /// - New resumed app → that package
  /// - Launcher / ignored / lock / screen-off → `null` (do nothing)
  /// - No relevant events in the window → [keepIfNoEvent] (keep same app)
  Future<String?> currentForegroundPackage({String? keepIfNoEvent}) async {
    final end = DateTime.now();
    // Long enough to catch app switches; not used alone for "still in app".
    final start = end.subtract(const Duration(minutes: 2));
    final events = await UsageStats.queryEvents(start, end);

    final points = <UsageEventPoint>[];
    for (final event in events) {
      final pkg = event.packageName ?? '';
      final type = event.eventTypeValue;
      final time = int.tryParse(event.timeStamp ?? '') ?? 0;
      if (type == null || time <= 0) continue;
      // Only walk events that change "is a trackable app open?".
      if (isForegroundResumeEvent(type) ||
          isForegroundPauseEvent(type) ||
          isScreenIdleEvent(type)) {
        points.add(
          UsageEventPoint(
            packageName: pkg,
            eventType: type,
            timeStampMs: time,
          ),
        );
      }
    }

    // Quiet window (still inside the same app) — keep counting that package.
    if (points.isEmpty) return keepIfNoEvent;

    points.sort((a, b) => a.timeStampMs.compareTo(b.timeStampMs));

    String? foreground;
    for (final event in points) {
      // Lock screen or display off → idle; never count over the keyguard.
      if (isScreenIdleEvent(event.eventType)) {
        foreground = null;
        continue;
      }

      if (isForegroundResumeEvent(event.eventType)) {
        final pkg = event.packageName;
        // Home / system chrome resume → explicitly idle (no keepIfNoEvent).
        if (pkg.isEmpty || _isIgnoredPackage(pkg)) {
          foreground = null;
        } else {
          foreground = pkg;
        }
        continue;
      }

      if (isForegroundPauseEvent(event.eventType)) {
        final pkg = event.packageName;
        // Matching pause (or empty OEM pause) closes the open session.
        if (foreground != null && (pkg.isEmpty || pkg == foreground)) {
          foreground = null;
        }
      }
    }

    // After processing events we know home/lock/paused — do not fall back.
    return foreground;
  }

  /// Whether [packageName] should be skipped for live counting.
  bool _isIgnoredPackage(String packageName) {
    if (_ignoredPackages.contains(packageName)) return true;
    if (packageName.startsWith('com.android.launcher')) return true;
    if (packageName.contains('launcher')) return true;
    return false;
  }

  /// Resolves a human-readable label for [packageName].
  Future<String> resolveAppName(String packageName) async {
    try {
      final info = await UsageStats.getAppInfo(packageName);
      final name = info?.appName;
      // Fall back to a humanized package id when PackageManager has no label.
      if (name == null || name.isEmpty) {
        return humanizePackageName(packageName);
      }
      return name;
    } catch (_) {
      return humanizePackageName(packageName);
    }
  }

  /// Resolves optional PNG icon bytes for [packageName].
  Future<Uint8List?> resolveIcon(String packageName) async {
    try {
      return await UsageStats.getAppIcon(packageName);
    } catch (_) {
      return null;
    }
  }

  /// Turns a package id into a short display name.
  ///
  /// Example: `com.google.android.youtube` → `Youtube`.
  static String humanizePackageName(String packageName) {
    final parts = packageName.split('.');
    const skip = {
      'android',
      'app',
      'apps',
      'com',
      'org',
      'io',
      'google',
      'main',
    };
    for (var i = parts.length - 1; i >= 0; i--) {
      final part = parts[i];
      if (part.isEmpty || skip.contains(part.toLowerCase())) continue;
      return part[0].toUpperCase() + part.substring(1);
    }
    return packageName;
  }
}
