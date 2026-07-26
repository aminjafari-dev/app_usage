import 'dart:typed_data';

import 'package:usage_stats/usage_stats.dart';

import 'package:app_usage/core/utils/duration_format.dart';

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

  /// Common launcher package prefixes/noise to skip when detecting foreground.
  static const _ignoredPackages = <String>{
    ownPackageName,
    'com.android.systemui',
    'com.google.android.apps.nexuslauncher',
    'com.android.launcher',
    'com.android.launcher3',
    'com.miui.home',
    'com.sec.android.app.launcher',
    'com.huawei.android.launcher',
    'com.oppo.launcher',
    'com.bbk.launcher2',
  };

  /// Returns whether PACKAGE_USAGE_STATS is granted.
  Future<bool> hasUsagePermission() async {
    return await UsageStats.checkUsagePermission() ?? false;
  }

  /// Opens the system Usage Access settings screen.
  Future<void> requestUsagePermission() async {
    await UsageStats.grantUsagePermission();
  }

  /// Seeds today's totals from UsageStats aggregates (milliseconds → seconds).
  ///
  /// Useful at tracking start to catch time spent before this process ran.
  Future<List<UsageInfoModel>> queryTodayAggregates() async {
    final end = DateTime.now();
    final start = startOfToday(end);
    final map = await UsageStats.queryAndAggregateUsageStats(start, end);

    final results = <UsageInfoModel>[];
    for (final entry in map.entries) {
      final info = entry.value;
      final packageName = info.packageName ?? entry.key;
      // Skip empty or ignored system packages.
      if (packageName.isEmpty || _ignoredPackages.contains(packageName)) {
        continue;
      }

      final ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
      final seconds = (ms / 1000).round();
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
  /// Returns null when the top app is a launcher/system UI we choose to ignore.
  Future<String?> currentForegroundPackage() async {
    final end = DateTime.now();
    // Look back a short window so we catch the latest ACTIVITY_RESUMED event.
    final start = end.subtract(const Duration(seconds: 10));
    final events = await UsageStats.queryEvents(start, end);

    String? lastPackage;
    for (final event in events) {
      final type = event.eventType;
      // MOVE_TO_FOREGROUND / ACTIVITY_RESUMED are type "1" in usage_stats.
      if (type == '1' || type == '15') {
        final pkg = event.packageName;
        if (pkg != null && pkg.isNotEmpty) {
          lastPackage = pkg;
        }
      }
    }

    if (lastPackage == null) return null;
    if (_ignoredPackages.contains(lastPackage)) return null;
    if (lastPackage.startsWith('com.android.launcher')) return null;
    return lastPackage;
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
