import 'dart:ui' show PlatformDispatcher;

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

/// Wraps `flutter_overlay_window` for permission + show/hide + messaging.
///
/// How to use:
/// ```dart
/// final overlay = OverlayDataSource();
/// if (!await overlay.hasPermission()) await overlay.requestPermission();
/// await overlay.show();
/// ```
class OverlayDataSource {
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
  Future<void> show({
    bool forceRestart = false,
    BadgeAppearance? appearance,
  }) async {
    final active = await FlutterOverlayWindow.isActive();
    // Avoid stacking multiple overlay windows if tracking restarts.
    if (active) {
      if (!forceRestart) return;
      await FlutterOverlayWindow.closeOverlay();
    }

    // Prefer an explicit appearance; otherwise load the user's saved scale.
    final resolved = appearance ?? await _loadAppearance();
    final size = _physicalSizeFor(resolved);
    await FlutterOverlayWindow.showOverlay(
      height: size.height,
      width: size.width,
      alignment: OverlayAlignment.topCenter,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      overlayTitle: 'App Usage',
      overlayContent: 'Live usage counter is running',
      // Keep it near the top instead of snapping to a side edge.
      positionGravity: PositionGravity.none,
      // Slight offset so the pill sits just under the status bar (dp → px
      // is handled inside the plugin for startPosition).
      startPosition: const OverlayPosition(0, 40),
    );
  }

  /// Logical chip size (dp) for [appearance] — used by overlay-side resize.
  ///
  /// How to use: call from the overlay isolate with
  /// [FlutterOverlayWindow.resizeOverlay], which applies `dp → px` natively.
  /// Do **not** call resize from the main isolate.
  ///
  /// Pass [sizeMultiplier] `1.5` during the open-app intro so the temporarily
  /// larger chip is not clipped by the native overlay window.
  static ({int width, int height}) logicalSizeFor(
    BadgeAppearance appearance, {
    double sizeMultiplier = 1.0,
  }) {
    final scale =
        appearance.sizeScale.clamp(0.5, 1.5) * sizeMultiplier.clamp(1.0, 1.5);
    // Keep these slightly above the painted chip so long h:mm:ss values and
    // drag hit-targets still fit after the user scales the badge.
    return (
      width: (140.0 * scale).round(),
      height: (36.0 * scale).round(),
    );
  }

  /// Converts logical chip size × badge scale into WindowManager pixels.
  ///
  /// Used only by [show] — `showOverlay` takes raw px, unlike resizeOverlay.
  ({int width, int height}) _physicalSizeFor(BadgeAppearance appearance) {
    final logical = logicalSizeFor(appearance);
    final dpr = PlatformDispatcher.instance.views.first.devicePixelRatio;
    return (
      width: (logical.width * dpr).round(),
      height: (logical.height * dpr).round(),
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
