import 'package:flutter_test/flutter_test.dart';

import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/utils/usage_time_calculator.dart';

void main() {
  test('formatUsageDuration uses mm:ss under one hour', () {
    expect(formatUsageDuration(75), '01:15');
  });

  test('formatUsageDuration uses h:mm:ss at one hour or more', () {
    expect(formatUsageDuration(3661), '1:01:01');
  });

  group('sumForegroundMsByPackage', () {
    // Realistic epoch midnight so pre-midnight lookback stays positive.
    const startMs = 1_722_038_400_000; // fixed "local midnight"
    const endMs = startMs + 60 * 60 * 1000; // one hour later

    bool ignoreLauncher(String pkg) =>
        pkg == 'com.android.launcher3' || pkg == 'com.android.systemui';

    test('counts a simple resume→pause session inside today', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 15, // ACTIVITY_RESUMED
            timeStampMs: startMs + 10_000,
          ),
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 16, // ACTIVITY_PAUSED
            timeStampMs: startMs + 40_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: endMs,
        isIgnoredPackage: ignoreLauncher,
      );

      expect(ms['org.telegram.messenger'], 30_000);
    });

    test('clips a session that started before midnight to today only', () {
      // Telegram was open for 49 minutes yesterday, then paused 30s after midnight.
      // Bucket aggregates would report ~49½ min; events must report only 30s.
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 1, // MOVE_TO_FOREGROUND (pre-midnight)
            timeStampMs: startMs - 49 * 60 * 1000,
          ),
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 2, // MOVE_TO_BACKGROUND
            timeStampMs: startMs + 30_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: endMs,
        isIgnoredPackage: ignoreLauncher,
      );

      expect(ms['org.telegram.messenger'], 30_000);
    });

    test('counts an still-open session until rangeEndMs', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'com.google.android.youtube',
            eventType: 15,
            timeStampMs: startMs + 50_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: startMs + 80_000,
        isIgnoredPackage: ignoreLauncher,
      );

      expect(ms['com.google.android.youtube'], 30_000);
    });

    test('closes previous app when another resumes', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 15,
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 15,
            timeStampMs: startMs + 20_000,
          ),
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 16,
            timeStampMs: startMs + 50_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: endMs,
        isIgnoredPackage: ignoreLauncher,
      );

      expect(ms['org.telegram.messenger'], 20_000);
      expect(ms['com.instagram.android'], 30_000);
    });

    test('does not count launcher / ignored packages', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 15,
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'com.android.launcher3',
            eventType: 15,
            timeStampMs: startMs + 10_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: startMs + 60_000,
        isIgnoredPackage: ignoreLauncher,
      );

      expect(ms['org.telegram.messenger'], 10_000);
      expect(ms.containsKey('com.android.launcher3'), isFalse);
    });
  });

  group('mergeTodaySeconds', () {
    test('keeps event total when cache is lower', () {
      expect(
        mergeTodaySeconds(eventSeconds: 100, cachedSeconds: 80),
        100,
      );
    });

    test('keeps live cache when only slightly ahead of events', () {
      expect(
        mergeTodaySeconds(eventSeconds: 100, cachedSeconds: 105),
        105,
      );
    });

    test('discards wildly inflated cache (yesterday bleed)', () {
      // 49:29 cache vs ~30s of real today events must not win via max().
      expect(
        mergeTodaySeconds(eventSeconds: 30, cachedSeconds: 49 * 60 + 29),
        30,
      );
    });
  });
}
