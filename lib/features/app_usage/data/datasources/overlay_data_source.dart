import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Payload pushed from the main isolate to the overlay UI each tick.
///
/// How to use:
/// ```dart
/// await overlay.sendTick(OverlayTickPayload(
///   packageName: 'com.app',
///   appName: 'App',
///   todaySeconds: 42,
/// ));
/// ```
class OverlayTickPayload {
  /// Creates a tick payload for the glassy counter.
  const OverlayTickPayload({
    required this.packageName,
    required this.appName,
    required this.todaySeconds,
  });

  final String packageName;
  final String appName;
  final int todaySeconds;

  /// Encodes fields for [FlutterOverlayWindow.shareData].
  Map<String, dynamic> toMap() => {
        'packageName': packageName,
        'appName': appName,
        'todaySeconds': todaySeconds,
      };

  /// Decodes a map received inside the overlay isolate.
  factory OverlayTickPayload.fromMap(Map<dynamic, dynamic> map) {
    return OverlayTickPayload(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      todaySeconds: (map['todaySeconds'] as num?)?.toInt() ?? 0,
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

    await FlutterOverlayWindow.showOverlay(
      height: 64,
      width: 200,
      alignment: OverlayAlignment.topCenter,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      overlayTitle: 'App Usage',
      overlayContent: 'Live usage counter is running',
      // Keep it near the top instead of snapping to a side edge.
      positionGravity: PositionGravity.none,
      // Slight offset so the pill sits just under the status bar.
      startPosition: const OverlayPosition(0, 48),
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
