import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_live_tracker.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';

/// Root widget living inside the overlay isolate.
///
/// How to use: mounted from [overlayMain] in `main.dart` when the floating
/// window starts. Owns [OverlayLiveTracker] so the badge keeps counting even
/// when the main application is backgrounded or removed from Recents.
///
/// Example flow:
/// 1. Main app calls showOverlay (starts foreground service)
/// 2. Android starts the overlay isolate with overlayMain
/// 3. [OverlayLiveTracker] polls UsageStats every second and updates the UI
/// 4. Main isolate can die; this isolate keeps the badge growing
class OverlayApp extends StatefulWidget {
  /// Creates the overlay root.
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  final OverlayLiveTracker _tracker = OverlayLiveTracker();

  String _appName = 'App';
  int _todaySeconds = 0;

  /// Real launcher icon (PNG) for the foreground app from PackageManager.
  ///
  /// How to use: updated each tick via [OverlayTickPayload.iconBytes] and
  /// passed to [UsageGlassCounter] so Telegram/YouTube/etc. show their own
  /// logos — never custom assets from ImagePath.
  List<int>? _iconBytes;

  @override
  void initState() {
    super.initState();
    // Start self-contained tracking in this isolate (survives main-app death).
    _tracker.start(
      onTick: (OverlayTickPayload payload) {
        if (!mounted) return;
        setState(() {
          _appName = payload.appName.isEmpty ? 'App' : payload.appName;
          _todaySeconds = payload.todaySeconds;
          // Keep previous icon if a tick omits bytes (should be rare).
          if (payload.iconBytes != null) {
            _iconBytes = payload.iconBytes;
          }
        });
      },
    );

    // Optional: still accept ticks from main for backwards compatibility,
    // but the live source of truth is now [_tracker] above.
    FlutterOverlayWindow.overlayListener.listen((event) {
      // Ignore our own outbound shareData echoes and malformed payloads.
      if (event is! Map) return;
      // Prefer tracker-driven updates; only apply external ticks if tracker
      // is somehow not running (should not happen in normal flow).
      if (_tracker.isRunning) return;
      final payload = OverlayTickPayload.fromMap(event);
      if (!mounted) return;
      setState(() {
        _appName = payload.appName.isEmpty ? 'App' : payload.appName;
        _todaySeconds = payload.todaySeconds;
        if (payload.iconBytes != null) {
          _iconBytes = payload.iconBytes;
        }
      });
    });
  }

  @override
  void dispose() {
    // Stop the 1s loop when the overlay service is torn down.
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: AppTheme.light(),
        // Fill the overlay window; the glass pill sizes itself to the window.
        child: UsageGlassCounter(
          appName: _appName,
          todaySeconds: _todaySeconds,
          // Real app logo from the device (PackageManager), not assets.
          iconBytes: _iconBytes,
        ),
      ),
    );
  }
}
