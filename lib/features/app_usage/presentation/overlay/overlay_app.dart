import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';

/// Root widget living inside the overlay isolate.
///
/// How to use: mounted from [overlayMain] in `main.dart` when the floating
/// window starts. Listens to [FlutterOverlayWindow.overlayListener] ticks.
///
/// Example flow:
/// 1. Main app calls showOverlay
/// 2. Android starts the overlay isolate with overlayMain
/// 3. shareData ticks update the glass counter
class OverlayApp extends StatefulWidget {
  /// Creates the overlay root.
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  String _appName = 'App';
  int _todaySeconds = 0;

  @override
  void initState() {
    super.initState();
    // Listen for tick maps from the main isolate tracker.
    FlutterOverlayWindow.overlayListener.listen((event) {
      // Ignore malformed payloads so a bad tick cannot kill the overlay.
      if (event is! Map) return;
      final payload = OverlayTickPayload.fromMap(event);
      if (!mounted) return;
      setState(() {
        _appName = payload.appName.isEmpty ? 'App' : payload.appName;
        _todaySeconds = payload.todaySeconds;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: AppTheme.light(),
        child: Center(
          child: UsageGlassCounter(
            appName: _appName,
            todaySeconds: _todaySeconds,
          ),
        ),
      ),
    );
  }
}
