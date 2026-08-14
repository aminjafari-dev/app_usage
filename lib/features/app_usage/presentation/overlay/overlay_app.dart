import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_usage/core/settings/badge_appearance_cubit.dart';
import 'package:app_usage/core/settings/usage_coach.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_data_source.dart';
import 'package:app_usage/features/app_usage/data/datasources/overlay_live_tracker.dart';
import 'package:app_usage/features/app_usage/presentation/overlay/usage_coach_card.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Root widget living inside the overlay isolate.
///
/// How to use: mounted from [overlayMain] in `main.dart` when the floating
/// window starts. Owns [OverlayLiveTracker] so the badge keeps counting even
/// when the main application is backgrounded or removed from Recents.
///
/// When a per-app daily limit is exceeded, the badge grows sideways to show
/// an idle alert. Tapping it opens a quote bubble docked under the pill.
class OverlayApp extends StatefulWidget {
  /// Creates the overlay root.
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  /// How often the native window size is re-applied as a safety net.
  static const Duration _windowGuardInterval = Duration(seconds: 10);

  /// Matches [_RevealSlot] so we shrink the window after the quote collapses.
  static const Duration _quoteCollapseDelay = Duration(milliseconds: 420);

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

  UsageCoach? _coach;

  /// True while the foreground app is past its daily cap.
  bool _overLimit = false;

  /// True while the quote bubble under the badge is open.
  bool _quoteOpen = false;

  /// Cursor into [UsageCoach.messageIds] for the next tap.
  int _quoteIndex = 0;

  /// True after the user has opened the quote at least once this session.
  bool _hasShownQuote = false;

  /// Last measured quote bubble size, used while the overlay window is expanded.
  Size? _quoteBubbleSize;

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
        // Null payload = home / lock / launcher — hide badge + close quote.
        if (payload == null) {
          final previous = _packageName;
          setState(() {
            _visible = false;
            _packageName = null;
            _playIntro = false;
            _overLimit = false;
            _quoteOpen = false;
          });
          unawaited(_coach?.onAppSwitched(previous));
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
            _quoteOpen = false;
            _quoteIndex = 0;
            _hasShownQuote = false;
            _quoteBubbleSize = null;
          }
        });

        if (switched) {
          unawaited(_coach?.onAppSwitched(previous));
          unawaited(_resizeOverlay(_appearance, sizeMultiplier: 1.5));
        }

        unawaited(_updateOverLimit(payload));
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
        if (sizeChanged) {
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
          _quoteOpen = false;
          _quoteIndex = 0;
          _hasShownQuote = false;
          _quoteBubbleSize = null;
        }
      });
      if (switched) {
        unawaited(_resizeOverlay(_appearance, sizeMultiplier: 1.5));
      }
      unawaited(_updateOverLimit(payload));
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
        _updateOverLimit(
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

  Future<void> _updateOverLimit(OverlayTickPayload payload) async {
    final coach = _coach;
    if (coach == null) return;

    final over = await coach.isOverLimit(
      packageName: payload.packageName,
      todaySeconds: payload.todaySeconds,
    );
    if (!mounted) return;
    // Foreground may have changed while we awaited prefs.
    if (_packageName != payload.packageName) return;
    if (over == _overLimit) return;

    if (over) {
      await _resizeOverlay(_appearance, overLimit: true, force: true);
      if (!mounted || _packageName != payload.packageName) return;
      setState(() => _overLimit = true);
      return;
    }

    setState(() {
      _overLimit = false;
      _quoteOpen = false;
      _quoteBubbleSize = null;
    });
    await Future<void>.delayed(_quoteCollapseDelay);
    if (!mounted) return;
    await _resizeOverlay(
      _appearance,
      overLimit: false,
      quoteOpen: false,
      force: true,
    );
  }

  Future<void> _onAlertTap() async {
    if (_quoteOpen) return;
    var nextIndex = _quoteIndex;
    if (_hasShownQuote && UsageCoach.messageIds.isNotEmpty) {
      nextIndex = (_quoteIndex + 1) % UsageCoach.messageIds.length;
    }
    final quote = _quoteFor(AppLocalizations.of(context), nextIndex);
    final quoteSize = UsageQuoteBubbleLayout(
      _appearance.sizeScale.clamp(
            BadgeAppearance.minSizeScale,
            BadgeAppearance.maxSizeScale,
          ) *
          _sizeMultiplier,
    ).measure(quote, Directionality.of(context));
    await _resizeOverlay(
      _appearance,
      quoteOpen: true,
      quoteBubbleSize: quoteSize,
      force: true,
    );
    if (!mounted) return;
    setState(() {
      _quoteIndex = nextIndex;
      _hasShownQuote = true;
      _quoteOpen = true;
    });
  }

  Future<void> _onQuoteClose() async {
    if (!_quoteOpen) return;
    setState(() {
      _quoteOpen = false;
      _quoteBubbleSize = null;
    });
    await Future<void>.delayed(_quoteCollapseDelay);
    if (!mounted) return;
    await _resizeOverlay(_appearance, quoteOpen: false, force: true);
  }

  String _quoteFor(AppLocalizations l10n, int index) {
    final ids = UsageCoach.messageIds;
    final quoteId = ids.isEmpty ? 'boss' : ids[index % ids.length];
    return coachMessageFor(l10n, quoteId);
  }

  /// Pass [force] to re-apply the size even when it looks unchanged.
  Future<void> _resizeOverlay(
    BadgeAppearance appearance, {
    double sizeMultiplier = 1.0,
    bool force = false,
    bool? overLimit,
    bool? quoteOpen,
    Size? quoteBubbleSize,
  }) async {
    try {
      _sizeMultiplier = sizeMultiplier;
      if (quoteBubbleSize != null) _quoteBubbleSize = quoteBubbleSize;
      final open = quoteOpen ?? _quoteOpen;
      final size = OverlayDataSource.logicalSizeFor(
        appearance,
        sizeMultiplier: sizeMultiplier,
        overLimit: overLimit ?? _overLimit,
        quoteOpen: open,
        quoteBubbleSize: open ? _quoteBubbleSize : null,
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
    if (!mounted) return;
    await _resizeOverlay(
      _appearance,
      sizeMultiplier: _sizeMultiplier,
      force: true,
    );
  }

  void _onIntroSizeBoost(double sizeBoost) {
    if (!mounted) return;
    unawaited(_resizeOverlay(_appearance, sizeMultiplier: sizeBoost));
  }

  @override
  void dispose() {
    _windowGuardTimer?.cancel();
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: _visible
          ? UsageGlassCounter(
              appName: _appName,
              todaySeconds: _todaySeconds,
              iconBytes: _iconBytes,
              sizeScale: _appearance.sizeScale,
              opacity: _appearance.opacity,
              playIntro: _playIntro,
              introKey: _packageName,
              onIntroSizeBoost: _onIntroSizeBoost,
              overLimit: _overLimit,
              quoteOpen: _quoteOpen,
              quote: _quoteFor(l10n, _quoteIndex),
              closeLabel: l10n.coachQuoteClose,
              alertLabel: l10n.coachLimitAlert,
              onAlertTap: () => unawaited(_onAlertTap()),
              onQuoteClose: () => unawaited(_onQuoteClose()),
            )
          : const SizedBox.shrink(),
    );
  }
}
