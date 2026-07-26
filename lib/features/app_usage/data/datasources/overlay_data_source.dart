import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

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
  Future<void> show({bool forceRestart = false}) async {
    final active = await FlutterOverlayWindow.isActive();
    // Avoid stacking multiple overlay windows if tracking restarts.
    if (active) {
      if (!forceRestart) return;
      await FlutterOverlayWindow.closeOverlay();
    }

    // showOverlay applies height/width as raw WindowManager pixels (not dp).
    // Convert logical design size → physical px so the glass pill fits on all
    // densities (e.g. 96dp ≈ 269px at 2.8x). Without this, a 96px-tall window
    // collapses to ~34 logical px and the Column overflows.
    //
    // How to use: keep [logicalHeight]/[logicalWidth] as the Flutter layout
    // size you want; only the native call is density-scaled.
    // Example: on a 3x device, height becomes 288 physical pixels.
    const logicalHeight = 96.0;
    const logicalWidth = 280.0;
    final dpr = PlatformDispatcher.instance.views.first.devicePixelRatio;
    await FlutterOverlayWindow.showOverlay(
      height: (logicalHeight * dpr).round(),
      width: (logicalWidth * dpr).round(),
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
}
