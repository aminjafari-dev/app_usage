import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/settings/badge_appearance_cubit.dart';
import 'package:app_usage/core/settings/usage_coach.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_live_tracker.dart';
import 'package:app_usage/features/app_usage/presentation/overlay/usage_coach_card.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';

/// Root widget living inside the overlay isolate.
///
/// How to use: mounted from [overlayMain] in `main.dart` when the floating
/// window starts. Owns [OverlayLiveTracker] so the badge keeps counting even
/// when the main application is backgrounded or removed from Recents.
///
/// Also evaluates per-app daily limits and expands into a gentle coach card
/// when the user stays past their limit.
class OverlayApp extends StatefulWidget {
  /// Creates the overlay root.
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  /// How often the native window size is re-applied as a safety net.
  static const Duration _windowGuardInterval = Duration(seconds: 10);

  /// Longest a full-screen coach card may stay up without user interaction.
  static const Duration _coachAutoSnooze = Duration(seconds: 60);

  final OverlayLiveTracker _tracker = OverlayLiveTracker();

  String _appName = 'App';
  int _todaySeconds = 0;

  /// Package of the app currently shown on the badge (null when hidden).
  String? _packageName;

  /// Whether the glassy top badge should be painted.
  bool _visible = false;

  /// When true, [UsageGlassCounter] plays the open-app intro sequence.
  bool _playIntro = false;

  /// Launcher icon (PNG) for the foreground app from PackageManager.
  List<int>? _iconBytes;

  /// Size / opacity from Settings (SharedPreferences + live shareData).
  BadgeAppearance _appearance = BadgeAppearance.defaults;

  /// Last native window size applied during intro settle (skip redundant resizes).
  int _lastOverlayWidth = 0;
  int _lastOverlayHeight = 0;

  /// Size multiplier last requested (the intro eases 1.5 → 1.0).
  double _sizeMultiplier = 1.0;

  /// Periodically re-applies the window size so it can never stay stale.
  Timer? _windowGuardTimer;

  /// Collapses the coach card if the user never answers it.
  Timer? _coachTimeoutTimer;

  UsageCoach? _coach;

  /// Active coach decision currently on screen (null = badge mode).
  CoachDecision? _coachDecision;

  /// Avoid re-recording [UsageCoach.markShown] for the same open card.
  bool _coachMarkedShown = false;

  /// Prevent overlapping expand/collapse animations.
  bool _resizingForCoach = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();

    _windowGuardTimer = Timer.periodic(
      _windowGuardInterval,
      (_) => unawaited(_ensureWindowMatchesMode()),
    );

    // Start self-contained tracking in this isolate (survives main-app death).
    _tracker.start(
      onTick: (OverlayTickPayload? payload) {
        if (!mounted) return;
        // Null payload = home / lock / launcher — hide badge + close coach.
        if (payload == null) {
          final previous = _packageName;
          setState(() {
            _visible = false;
            _packageName = null;
            _playIntro = false;
          });
          unawaited(_coach?.onAppSwitched(previous));
          if (_coachDecision != null) {
            unawaited(_dismissCoach());
          }
          return;
        }

        final switched = payload.packageName != _packageName;
        final previous = _packageName;
        setState(() {
          _visible = true;
          _appName = payload.appName.isEmpty ? 'App' : payload.appName;
          _todaySeconds = payload.todaySeconds;
          if (payload.iconBytes != null) {
            _iconBytes = payload.iconBytes;
          }
          if (switched) {
            _packageName = payload.packageName;
            _playIntro = true;
          }
        });

        if (switched) {
          unawaited(_coach?.onAppSwitched(previous));
          // Leaving a limited app while coach is open → collapse back to badge.
          if (_coachDecision != null &&
              _coachDecision!.packageName != payload.packageName) {
            unawaited(_dismissCoach());
          } else if (_coachDecision == null) {
            unawaited(_resizeOverlay(_appearance, sizeMultiplier: 1.5));
          }
        }

        unawaited(_evaluateCoach(payload));
      },
    );

    // Home can push seeded today totals (and legacy ticks) over shareData.
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is! Map) return;

      if (event['type'] == 'seedTotals') {
        final totals = event['totals'];
        if (totals is Map) {
          _tracker.applySeedTotals(totals);
        }
        return;
      }

      if (event['type'] == 'badgeAppearance') {
        final next = BadgeAppearance.fromMap(event);
        final sizeChanged = next.sizeScale != _appearance.sizeScale;
        if (!mounted) return;
        setState(() => _appearance = next);
        if (sizeChanged && _coachDecision == null) {
          unawaited(_resizeOverlay(next));
        }
        return;
      }

      if (_tracker.isRunning) return;
      final payload = OverlayTickPayload.fromMap(event);
      if (!mounted) return;
      if (payload.packageName.isEmpty) {
        setState(() => _visible = false);
        return;
      }
      final switched = payload.packageName != _packageName;
      setState(() {
        _visible = true;
        _appName = payload.appName.isEmpty ? 'App' : payload.appName;
        _todaySeconds = payload.todaySeconds;
        if (payload.iconBytes != null) {
          _iconBytes = payload.iconBytes;
        }
        if (switched) {
          _packageName = payload.packageName;
          _playIntro = true;
        }
      });
      if (switched && _coachDecision == null) {
        unawaited(_resizeOverlay(_appearance, sizeMultiplier: 1.5));
      }
      unawaited(_evaluateCoach(payload));
    });
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _appearance = BadgeAppearanceCubit.readFrom(prefs);
      _coach = UsageCoach(prefs);
    });
    // Limits may already be exceeded when the overlay boots.
    final package = _packageName;
    if (package != null) {
      unawaited(
        _evaluateCoach(
          OverlayTickPayload(
            packageName: package,
            appName: _appName,
            todaySeconds: _todaySeconds,
            iconBytes: _iconBytes,
          ),
        ),
      );
    }
  }

  Future<void> _evaluateCoach(OverlayTickPayload payload) async {
    final coach = _coach;
    if (coach == null) return;
    // Already showing a card for this package — keep it.
    if (_coachDecision != null) return;

    final decision = await coach.evaluate(
      packageName: payload.packageName,
      todaySeconds: payload.todaySeconds,
    );
    if (!mounted || !decision.shouldShow) return;
    // Foreground may have changed while we awaited prefs.
    if (_packageName != decision.packageName) return;

    await _showCoach(decision);
  }

  Future<void> _showCoach(CoachDecision decision) async {
    if (_resizingForCoach || _coachDecision != null) return;
    _resizingForCoach = true;
    try {
      await _expandForCoach();
      if (!mounted) return;
      setState(() {
        _coachDecision = decision;
        _coachMarkedShown = false;
      });
      if (!_coachMarkedShown) {
        _coachMarkedShown = true;
        await _coach?.markShown(decision);
      }
      // The expanded window covers the screen and consumes every touch, so an
      // unanswered card must never be able to strand the user.
      _coachTimeoutTimer?.cancel();
      _coachTimeoutTimer = Timer(
        _coachAutoSnooze,
        () => unawaited(_onSnooze()),
      );
    } finally {
      _resizingForCoach = false;
    }
  }

  Future<void> _dismissCoach() async {
    _coachTimeoutTimer?.cancel();
    _coachTimeoutTimer = null;
    if (!mounted) return;
    setState(() {
      _coachDecision = null;
      _coachMarkedShown = false;
    });
    await _collapseToBadge();
  }

  Future<void> _onPause() async {
    final package = _coachDecision?.packageName;
    if (package != null) {
      await _coach?.acknowledge(package);
    }
    await _dismissCoach();
  }

  Future<void> _onSnooze() async {
    final package = _coachDecision?.packageName;
    if (package != null) {
      await _coach?.snooze(package);
    }
    await _dismissCoach();
  }

  Future<void> _onMuteToday() async {
    final package = _coachDecision?.packageName;
    if (package != null) {
      await _coach?.muteToday(package);
    }
    await _dismissCoach();
  }

  /// Grows the native overlay to cover the screen for the center card.
  Future<void> _expandForCoach() async {
    try {
      final view = PlatformDispatcher.instance.views.first;
      final logical = view.physicalSize / view.devicePixelRatio;
      final width = logical.width.round().clamp(320, 5000);
      final height = logical.height.round().clamp(480, 5000);
      _lastOverlayWidth = width;
      _lastOverlayHeight = height;
      await FlutterOverlayWindow.resizeOverlay(width, height, false);
      await FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 0));
    } catch (_) {
      // Card may still paint inside a smaller window.
    }
  }

  /// Restores the small draggable badge window after the coach card closes.
  Future<void> _collapseToBadge() async {
    try {
      await _resizeOverlay(_appearance, force: true);
      await FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 40));
    } catch (_) {
      // Badge may already match; ignore.
    }
  }

  /// Pass [force] to re-apply the size even when it looks unchanged.
  Future<void> _resizeOverlay(
    BadgeAppearance appearance, {
    double sizeMultiplier = 1.0,
    bool force = false,
  }) async {
    try {
      _sizeMultiplier = sizeMultiplier;
      final size = OverlayDataSource.logicalSizeFor(
        appearance,
        sizeMultiplier: sizeMultiplier,
      );
      if (!force &&
          size.width == _lastOverlayWidth &&
          size.height == _lastOverlayHeight) {
        return;
      }
      _lastOverlayWidth = size.width;
      _lastOverlayHeight = size.height;
      await FlutterOverlayWindow.resizeOverlay(size.width, size.height, true);
    } catch (_) {
      // Window may already be closing; painted scale/opacity still update.
    }
  }

  /// Re-applies the window size that the current mode needs.
  ///
  /// The native watchdog can recreate the overlay window while this isolate
  /// keeps running, because the overlay Flutter engine is cached. That new
  /// window is sized from the plugin's static config rather than from our
  /// state, so re-asserting is what stops an oversized transparent window from
  /// silently swallowing every touch on the device.
  Future<void> _ensureWindowMatchesMode() async {
    if (!mounted || _resizingForCoach) return;
    if (_coachDecision != null) {
      await _expandForCoach();
      return;
    }
    await _resizeOverlay(
      _appearance,
      sizeMultiplier: _sizeMultiplier,
      force: true,
    );
  }

  void _onIntroSizeBoost(double sizeBoost) {
    if (!mounted || _coachDecision != null) return;
    unawaited(_resizeOverlay(_appearance, sizeMultiplier: sizeBoost));
  }

  @override
  void dispose() {
    _windowGuardTimer?.cancel();
    _coachTimeoutTimer?.cancel();
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _coachDecision != null
          ? UsageCoachCard(
              appName: _appName,
              decision: _coachDecision!,
              iconBytes: _iconBytes,
              blurBackground: true,
              onPause: () => unawaited(_onPause()),
              onSnooze: () => unawaited(_onSnooze()),
              onMuteToday: () => unawaited(_onMuteToday()),
            )
          : (_visible
              ? UsageGlassCounter(
                  appName: _appName,
                  todaySeconds: _todaySeconds,
                  iconBytes: _iconBytes,
                  sizeScale: _appearance.sizeScale,
                  opacity: _appearance.opacity,
                  playIntro: _playIntro,
                  introKey: _packageName,
                  onIntroSizeBoost: _onIntroSizeBoost,
                )
              : const SizedBox.shrink()),
    );
  }
}
