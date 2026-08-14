import 'dart:ui' show PlatformDispatcher, Size;

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/settings/badge_appearance_cubit.dart';

/// Payload pushed from the main isolate to the overlay UI each tick.
///
/// How to use:
/// ```dart
/// await overlay.sendTick(OverlayTickPayload(
///   packageName: 'com.telegram.messenger',
///   appName: 'Telegram',
///   todaySeconds: 42,
///   iconBytes: await usageStats.resolveIcon(package),
/// ));
/// ```
///
/// [iconBytes] is the real launcher icon from Android PackageManager (PNG),
/// not a custom asset — so Telegram shows Telegram's icon, YouTube shows
/// YouTube's, etc.
class OverlayTickPayload {
  /// Creates a tick payload for the glassy counter.
  const OverlayTickPayload({
    required this.packageName,
    required this.appName,
    required this.todaySeconds,
    this.iconBytes,
  });

  final String packageName;
  final String appName;
  final int todaySeconds;

  /// Optional PNG bytes from [UsageStats.getAppIcon] for the active package.
  ///
  /// How to use: pass through to [UsageGlassCounter.iconBytes] so the overlay
  /// badge shows the foreground app's real logo. Null → fallback apps glyph.
  final List<int>? iconBytes;

  /// Encodes fields for [FlutterOverlayWindow.shareData].
  ///
  /// Set [includeIcon] false on every-second ticks to avoid shipping large
  /// PNG lists over the isolate bridge; send the icon only on app switches.
  /// Example: `payload.toMap(includeIcon: packageJustChanged)`.
  Map<String, dynamic> toMap({bool includeIcon = true}) {
    final map = <String, dynamic>{
      'packageName': packageName,
      'appName': appName,
      'todaySeconds': todaySeconds,
    };
    // Only attach icon bytes when the receiver needs a fresh logo.
    if (includeIcon && iconBytes != null) {
      map['iconBytes'] = iconBytes;
    }
    return map;
  }

  /// Decodes a map received inside the overlay isolate (or main via shareData).
  factory OverlayTickPayload.fromMap(Map<dynamic, dynamic> map) {
    // MethodChannel may deliver icon bytes as List<int> or Uint8List.
    final rawIcon = map['iconBytes'];
    List<int>? iconBytes;
    if (rawIcon is List) {
      iconBytes = rawIcon.map((e) => (e as num).toInt()).toList();
    }
    return OverlayTickPayload(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      todaySeconds: (map['todaySeconds'] as num?)?.toInt() ?? 0,
      iconBytes: iconBytes,
    );
  }
}

/// Native overlay window geometry in pixels plus its notification copy.
///
/// How to use: returned by [OverlayDataSource.show] so callers can hand the
/// same values to native recovery code.
/// Example: `battery.cacheOverlayWindow(width: c.width, height: c.height, ...)`.
class OverlayWindowConfig {
  /// Creates a window config.
  const OverlayWindowConfig({
    required this.width,
    required this.height,
    required this.title,
    required this.content,
  });

  /// Window width in physical pixels (what `showOverlay` expects).
  final int width;

  /// Window height in physical pixels.
  final int height;

  /// Foreground-service notification title.
  final String title;

  /// Foreground-service notification body.
  final String content;
}

/// Wraps `flutter_overlay_window` for permission + show/hide + messaging.
///
/// How to use:
/// ```dart
/// final overlay = OverlayDataSource();
/// if (!await overlay.hasPermission()) await overlay.requestPermission();
/// await overlay.show();
/// ```
class OverlayDataSource {
  /// Notification title shown while the overlay foreground service runs.
  static const String notificationTitle = 'App Usage';

  /// Notification body shown while the overlay foreground service runs.
  static const String notificationContent = 'Live usage counter is running';

  /// Whether the user granted Display-over-other-apps.
  Future<bool> hasPermission() async {
    return FlutterOverlayWindow.isPermissionGranted();
  }

  /// Whether the overlay foreground service / window is currently showing.
  ///
  /// How to use: after the main activity is recreated, check this before
  /// calling [show] so we do not restart an already-running live tracker.
  /// Example: `if (!await overlay.isActive()) await overlay.show();`
  Future<bool> isActive() async {
    return FlutterOverlayWindow.isActive();
  }

  /// Opens the system overlay permission screen.
  Future<bool?> requestPermission() async {
    return FlutterOverlayWindow.requestPermission();
  }

  /// Shows the small draggable glassy counter overlay at the top of the screen.
  ///
  /// How to use: call after overlay permission is granted and tracking starts.
  /// Example: the counter appears at the top center over Instagram/Chrome/etc.
  ///
  /// Pass [forceRestart] true when repositioning an already-visible overlay
  /// (e.g. after upgrading from a corner placement to top-center).
  /// Pass [appearance] to size the native window for the user's badge scale.
  ///
  /// Returns the geometry that was applied (or would be applied when the
  /// overlay is already visible) so callers can cache it for native recovery.
  Future<OverlayWindowConfig> show({
    bool forceRestart = false,
    BadgeAppearance? appearance,
  }) async {
    // Prefer an explicit appearance; otherwise load the user's saved scale.
    final resolved = appearance ?? await _loadAppearance();
    final config = windowConfigFor(resolved);

    final active = await FlutterOverlayWindow.isActive();
    // Avoid stacking multiple overlay windows if tracking restarts.
    if (active) {
      if (!forceRestart) return config;
      await FlutterOverlayWindow.closeOverlay();
    }

    await FlutterOverlayWindow.showOverlay(
      height: config.height,
      width: config.width,
      alignment: OverlayAlignment.topCenter,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      overlayTitle: config.title,
      overlayContent: config.content,
      // Keep it near the top instead of snapping to a side edge.
      positionGravity: PositionGravity.none,
      // Slight offset so the pill sits just under the status bar (dp → px
      // is handled inside the plugin for startPosition).
      startPosition: const OverlayPosition(0, 40),
    );
    return config;
  }

  /// Window geometry for [appearance], loading saved values when omitted.
  ///
  /// How to use: call before [show] (or when the overlay is already running) to
  /// refresh the native watchdog's cached badge size.
  Future<OverlayWindowConfig> resolveWindowConfig({
    BadgeAppearance? appearance,
  }) async {
    return windowConfigFor(appearance ?? await _loadAppearance());
  }

  /// Extra logical width (dp at scale 1) for the over-limit alert glyph.
  static const double overLimitExtraWidth = 32;

  /// Gap between the badge and the quote bubble (dp at scale 1).
  static const double quoteBubbleGap = 4;

  /// Breathing room around measured quote geometry (dp).
  static const double quoteWindowPad = 8;

  /// Fallback extra height when quote size has not been measured yet.
  static const double quoteBubbleExtraHeight = 160;

  /// Logical chip size (dp) for [appearance] — used by overlay-side resize.
  ///
  /// How to use: call from the overlay isolate with
  /// [FlutterOverlayWindow.resizeOverlay], which applies `dp → px` natively.
  /// Do **not** call resize from the main isolate.
  ///
  /// Pass [sizeMultiplier] `1.5` during the open-app intro so the temporarily
  /// larger chip is not clipped by the native overlay window.
  /// Pass [overLimit] / [quoteOpen] when the badge grows sideways for the
  /// alert icon, or downward for the quote bubble.
  /// Pass [quoteBubbleSize] (from [UsageQuoteBubbleLayout.measure]) so the
  /// window matches a long quote instead of clipping it.
  static ({int width, int height}) logicalSizeFor(
    BadgeAppearance appearance, {
    double sizeMultiplier = 1.0,
    bool overLimit = false,
    bool quoteOpen = false,
    Size? quoteBubbleSize,
  }) {
    final scale = appearance.sizeScale.clamp(
          BadgeAppearance.minSizeScale,
          BadgeAppearance.maxSizeScale,
        ) *
        sizeMultiplier.clamp(1.0, 1.5);
    // Keep these slightly above the painted chip so long h:mm:ss values and
    // drag hit-targets still fit after the user scales the badge.
    final extraWidth = (overLimit ? overLimitExtraWidth : 0.0) * scale;
    final badgeWidth = 140.0 * scale + extraWidth;
    final badgeHeight = 36.0 * scale;
    if (!quoteOpen) {
      return (width: badgeWidth.round(), height: badgeHeight.round());
    }
    final quote = quoteBubbleSize ??
        Size(260.0 * scale, quoteBubbleExtraHeight * scale);
    final width = badgeWidth > quote.width ? badgeWidth : quote.width;
    return (
      width: (width + quoteWindowPad).round(),
      height: (badgeHeight +
              quoteBubbleGap * scale +
              quote.height +
              quoteWindowPad)
          .round(),
    );
  }

  /// Converts logical chip size × badge scale into WindowManager pixels.
  ///
  /// Used by [show] and by native recovery — `showOverlay` takes raw px, unlike
  /// resizeOverlay.
  static OverlayWindowConfig windowConfigFor(BadgeAppearance appearance) {
    final logical = logicalSizeFor(appearance);
    final dpr = PlatformDispatcher.instance.views.first.devicePixelRatio;
    return OverlayWindowConfig(
      width: (logical.width * dpr).round(),
      height: (logical.height * dpr).round(),
      title: notificationTitle,
      content: notificationContent,
    );
  }

  Future<BadgeAppearance> _loadAppearance() async {
    final prefs = await SharedPreferences.getInstance();
    return BadgeAppearanceCubit.readFrom(prefs);
  }

  /// Hides the overlay if it is currently visible.
  Future<void> hide() async {
    final active = await FlutterOverlayWindow.isActive();
    if (!active) return;
    await FlutterOverlayWindow.closeOverlay();
  }

  /// Sends the latest app name + today's seconds to the overlay isolate.
  Future<void> sendTick(OverlayTickPayload payload) async {
    final active = await FlutterOverlayWindow.isActive();
    // No-op when the overlay was dismissed or never shown.
    if (!active) return;
    await FlutterOverlayWindow.shareData(payload.toMap());
  }

  /// Pushes Home's seeded today totals into the overlay isolate.
  ///
  /// Useful right after [show] so the badge starts from UsageStats (e.g. 2h
  /// Telegram) instead of `00:00` when the overlay hydrate races or misses
  /// SharedPreferences written by the main isolate.
  ///
  /// Example: `{ 'org.telegram.messenger': 7200 }` → overlay counter shows 2:00:00.
  Future<void> sendTodaySeed(Map<String, int> totalsByPackage) async {
    final active = await FlutterOverlayWindow.isActive();
    if (!active || totalsByPackage.isEmpty) return;
    await FlutterOverlayWindow.shareData({
      'type': 'seedTotals',
      'totals': totalsByPackage,
    });
  }
}
