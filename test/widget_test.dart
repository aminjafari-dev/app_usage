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
            eventType: 1, // ACTIVITY_RESUMED
            timeStampMs: startMs + 10_000,
          ),
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 2, // ACTIVITY_PAUSED
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
            eventType: 1,
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
            eventType: 1,
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 1,
            timeStampMs: startMs + 20_000,
          ),
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 2,
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
            eventType: 1,
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'com.android.launcher3',
            eventType: 1,
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

    test('stops counting when the lock screen is shown', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 1, // ACTIVITY_RESUMED
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'android',
            eventType: 17, // KEYGUARD_SHOWN
            timeStampMs: startMs + 20_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: startMs + 60_000,
        isIgnoredPackage: ignoreLauncher,
      );

      // Only the 20s before lock — not the remaining 40s on the keyguard.
      expect(ms['org.telegram.messenger'], 20_000);
    });

    test('keeps counting across an in-app screen change', () {
      // Back press inside Instagram: the stop of the activity the user left
      // lands *after* the underlying activity resumed.
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 2, // story activity paused
            timeStampMs: startMs + 10_000,
          ),
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 1, // feed activity resumed
            timeStampMs: startMs + 10_200,
          ),
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 23, // story activity stopped
            timeStampMs: startMs + 10_600,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: startMs + 60_000,
        isIgnoredPackage: ignoreLauncher,
      );

      // Session must run to the end of the range, not stop at the ACTIVITY_STOPPED.
      expect(ms['com.instagram.android'], 49_800);
    });

    test('a shade resume does not truncate the running session', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'com.instagram.android',
            eventType: 1,
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'com.android.systemui',
            eventType: 1, // heads-up notification / shade pulled down
            timeStampMs: startMs + 20_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: startMs + 60_000,
        isIgnoredPackage: ignoreLauncher,
        isTransientSystemPackage: (pkg) => pkg == 'com.android.systemui',
      );

      expect(ms['com.instagram.android'], 60_000);
    });

    test('stops counting when the screen turns off', () {
      final ms = sumForegroundMsByPackage(
        events: const [
          UsageEventPoint(
            packageName: 'com.google.android.youtube',
            eventType: 1,
            timeStampMs: startMs,
          ),
          UsageEventPoint(
            packageName: 'android',
            eventType: 16, // SCREEN_NON_INTERACTIVE
            timeStampMs: startMs + 15_000,
          ),
        ],
        rangeStartMs: startMs,
        rangeEndMs: startMs + 60_000,
        isIgnoredPackage: ignoreLauncher,
      );

      expect(ms['com.google.android.youtube'], 15_000);
    });
  });

  group('resolveForegroundPackage', () {
    const nowMs = 1_722_038_400_000;
    const instagram = 'com.instagram.android';

    bool isIdle(String pkg) =>
        pkg == 'com.android.launcher3' || pkg == 'com.example.app_usage';
    bool isTransient(String pkg) =>
        pkg == 'com.android.systemui' || pkg == 'android';

    String? resolve(List<UsageEventPoint> events, {String? seed}) {
      return resolveForegroundPackage(
        events: events,
        nowMs: nowMs,
        seedPackage: seed,
        isIdlePackage: isIdle,
        isTransientSystemPackage: isTransient,
      );
    }

    test('stays on the app when a stop lands after an in-app resume', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: instagram,
            eventType: 2,
            timeStampMs: nowMs - 8_000,
          ),
          UsageEventPoint(
            packageName: instagram,
            eventType: 1,
            timeStampMs: nowMs - 7_800,
          ),
          UsageEventPoint(
            packageName: instagram,
            eventType: 23,
            timeStampMs: nowMs - 7_400,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, instagram);
    });

    test('keeps the app when only system chrome resumed', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: 'com.android.systemui',
            eventType: 1,
            timeStampMs: nowMs - 3_000,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, instagram);
    });

    test('keeps the app when its resume scrolled out of the window', () {
      // Only an unrelated background app's event is left in the window.
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: 'com.whatsapp',
            eventType: 2,
            timeStampMs: nowMs - 30_000,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, instagram);
    });

    test('holds the badge briefly after a bare pause', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: instagram,
            eventType: 2,
            timeStampMs: nowMs - 400,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, instagram);
    });

    test('hides once a pause is older than the grace window', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: instagram,
            eventType: 2,
            timeStampMs: nowMs - 5_000,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, isNull);
    });

    test('hides on the home screen', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: instagram,
            eventType: 2,
            timeStampMs: nowMs - 5_000,
          ),
          UsageEventPoint(
            packageName: 'com.android.launcher3',
            eventType: 1,
            timeStampMs: nowMs - 4_800,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, isNull);
    });

    test('hides on lock even when the app never paused', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: 'android',
            eventType: 17, // KEYGUARD_SHOWN
            timeStampMs: nowMs - 2_000,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, isNull);
    });

    test('switches to a newly resumed app', () {
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: 'org.telegram.messenger',
            eventType: 1,
            timeStampMs: nowMs - 1_000,
          ),
        ],
        seed: instagram,
      );

      expect(pkg, 'org.telegram.messenger');
    });

    test('recovers the open app from a wide rescan while hidden', () {
      // Badge already hidden (no seed) — a deep scan finds the last resume.
      final pkg = resolve(
        const [
          UsageEventPoint(
            packageName: instagram,
            eventType: 1,
            timeStampMs: nowMs - 15 * 60 * 1000,
          ),
        ],
      );

      expect(pkg, instagram);
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
