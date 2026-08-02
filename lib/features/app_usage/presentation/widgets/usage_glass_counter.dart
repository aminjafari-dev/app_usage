import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Minimal timer chip — foreground app logo + bold mm:ss (or h:mm:ss).
///
/// How to use:
/// ```dart
/// UsageGlassCounter(
///   appName: 'Instagram',
///   todaySeconds: 120,
///   iconBytes: preview.iconBytes,
/// );
/// ```
///
/// Shared by the floating overlay and the home-page preview.
/// Pass [iconBytes] from PackageManager so the chip shows the open app's logo.
///
/// With [playIntro] true, opening a new app runs:
/// 1.5× circle → scale down to user size → pill expands right → duration fades in.
class UsageGlassCounter extends StatefulWidget {
  /// Creates the minimal timer chip.
  ///
  /// [sizeScale] and [opacity] come from badge appearance settings
  /// (`1.0` / `0.9` are the defaults).
  const UsageGlassCounter({
    super.key,
    required this.appName,
    required this.todaySeconds,
    this.iconBytes,
    this.compact = true,
    this.sizeScale = 1.0,
    this.opacity = 0.9,
    this.playIntro = false,
    this.introKey,
    this.onIntroSizeBoost,
    this.onIntroComplete,
  });

  final String appName;
  final int todaySeconds;
  final List<int>? iconBytes;
  final bool compact;
  final double sizeScale;
  final double opacity;

  /// When true, plays the open-app intro (overlay only; previews stay static).
  final bool playIntro;

  /// Restart the intro whenever this value changes (typically package name).
  final Object? introKey;

  /// Current size boost vs user size (`1.5` → `1.0`) while the intro runs.
  ///
  /// How to use: resize the native overlay window to match so height/width
  /// ease down with the circle before the pill expands.
  final ValueChanged<double>? onIntroSizeBoost;

  /// Called once the full intro sequence finishes.
  final VoidCallback? onIntroComplete;

  @override
  State<UsageGlassCounter> createState() => _UsageGlassCounterState();
}

class _UsageGlassCounterState extends State<UsageGlassCounter>
    with SingleTickerProviderStateMixin {
  /// Peak multiplier vs user size at the start of the intro.
  static const double _introBoost = 1.5;

  /// Hold the big circle before scale-down / expand / reveal begin.
  static const Duration _introDelay = Duration(seconds: 1);

  /// Motion after the delay: scale down → expand right → show duration.
  static const Duration _introDuration = Duration(milliseconds: 1200);

  AnimationController? _controller;
  Animation<double>? _scaleDown;
  Animation<double>? _expand;
  Animation<double>? _textOpacity;

  Timer? _delayTimer;
  Object? _lastIntroKey;

  /// After the intro finishes we keep painting the final animation frame so
  /// there is no swap to a different layout (that swap caused a visible flash).
  bool _introSettled = false;

  @override
  void initState() {
    super.initState();
    if (widget.playIntro) {
      _ensureController();
      _startIntro();
    }
  }

  @override
  void didUpdateWidget(covariant UsageGlassCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.playIntro) {
      _disposeController();
      _introSettled = false;
      return;
    }
    _ensureController();
    // New foreground app (or first show) → replay the intro sequence.
    if (widget.introKey != _lastIntroKey ||
        widget.playIntro != oldWidget.playIntro) {
      _startIntro();
    }
  }

  void _ensureController() {
    if (_controller != null) return;
    final controller = AnimationController(
      vsync: this,
      duration: _introDuration,
    );
    // 1) Still a circle — ease from 1.5× down to the user-defined size.
    _scaleDown = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.38, curve: Curves.easeOutCubic),
    );
    // 2) Pill grows to the right; logo stays on the left.
    _expand = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.38, 0.78, curve: Curves.easeOutCubic),
    );
    // 3) Duration digits fade in as the pill opens.
    _textOpacity = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.58, 0.88, curve: Curves.easeOut),
    );
    // Drive native window size with the same boost as the painted chip.
    controller.addListener(_emitSizeBoost);
    controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      _introSettled = true;
      // Final exact 1.0 so the window never sticks slightly above user size.
      widget.onIntroSizeBoost?.call(1.0);
      widget.onIntroComplete?.call();
    });
    _controller = controller;
  }

  /// Maps scale-down progress to a boost and notifies the overlay window.
  void _emitSizeBoost() {
    final scaleDown = _scaleDown;
    if (scaleDown == null) return;
    final boost = lerpDouble(_introBoost, 1.0, scaleDown.value)!;
    widget.onIntroSizeBoost?.call(boost);
  }

  void _startIntro() {
    _lastIntroKey = widget.introKey;
    _introSettled = false;
    final controller = _controller;
    if (controller == null) return;

    _delayTimer?.cancel();
    // Park on the big circle for the delay, then run the motion.
    controller.stop();
    controller.value = 0;
    // Window / chip start at 1.5× for the hold.
    widget.onIntroSizeBoost?.call(_introBoost);

    _delayTimer = Timer(_introDelay, () {
      if (!mounted || widget.introKey != _lastIntroKey) return;
      controller.forward(from: 0);
    });
  }

  void _disposeController() {
    _delayTimer?.cancel();
    _delayTimer = null;
    _controller?.removeListener(_emitSizeBoost);
    _controller?.dispose();
    _controller = null;
    _scaleDown = null;
    _expand = null;
    _textOpacity = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    // Keep using the controller after completion so the last frame (== user
    // size) stays on screen — switching to the static path felt like a flash.
    if (widget.playIntro && controller != null) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final scaleDown = _introSettled ? 1.0 : _scaleDown!.value;
          return _buildChip(
            expand: _introSettled ? 1.0 : _expand!.value,
            textOpacity: _introSettled ? 1.0 : _textOpacity!.value,
            // scaleDown 0 → 1.5× circle; 1 → user-sized circle, then expand.
            sizeBoost: lerpDouble(_introBoost, 1.0, scaleDown)!,
          );
        },
      );
    }
    return _buildChip(expand: 1, textOpacity: 1, sizeBoost: 1);
  }

  Widget _buildChip({
    required double expand,
    required double textOpacity,
    required double sizeBoost,
  }) {
    final scale = widget.sizeScale.clamp(0.5, 1.5) * sizeBoost;
    final compact = widget.compact;
    final iconSize = (compact ? 18.0 : 22.0) * scale;
    final fontSize = (compact ? 13.0 : 15.0) * scale;
    final hPad = (compact ? 8.0 : 10.0) * scale;
    final vPad = (compact ? 5.0 : 7.0) * scale;
    final gap = (compact ? 6.0 : 8.0) * scale;

    // Top-left during intro so the logo stays put while the pill grows right;
    // top-center for static previews.
    return Align(
      alignment:
          widget.playIntro ? Alignment.topLeft : Alignment.topCenter,
      child: Opacity(
        opacity: widget.opacity.clamp(0.3, 1.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: AppTheme.overlayChipFill,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          // Logo anchored left; trailing content clips open to the right so the
          // chip starts as a circle and grows into the duration pill.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ChipAppLogo(iconBytes: widget.iconBytes, size: iconSize),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: expand.clamp(0.0, 1.0),
                  child: Opacity(
                    opacity: textOpacity.clamp(0.0, 1.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: gap),
                        Text(
                          formatUsageDuration(widget.todaySeconds),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.overlayChipText,
                            height: 1.0,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny circular launcher icon for the timer chip (fallback: sage clock).
class _ChipAppLogo extends StatelessWidget {
  const _ChipAppLogo({this.iconBytes, required this.size});

  final List<int>? iconBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    if (bytes == null || bytes.isEmpty) {
      return Icon(
        Icons.timelapse_rounded,
        size: size,
        color: AppTheme.overlayChipIcon,
      );
    }

    return ClipOval(
      child: Image.memory(
        Uint8List.fromList(bytes),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.timelapse_rounded,
          size: size,
          color: AppTheme.overlayChipIcon,
        ),
      ),
    );
  }
}

/// Circular app-icon (or fallback glyph).
class _IconBubble extends StatelessWidget {
  const _IconBubble({this.iconBytes, this.size = 28});

  final List<int>? iconBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    final glyphSize = size * 0.55;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.divider,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? Icon(Icons.apps_rounded, size: glyphSize, color: AppTheme.primary)
          : Image.memory(
              Uint8List.fromList(bytes),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.apps_rounded,
                size: glyphSize,
                color: AppTheme.primary,
              ),
            ),
    );
  }
}

/// List tile for one app — avatar + name + duration pill.
///
/// How to use inside a ListView / card with [AppUsageEntity] items.
class UsageAppTile extends StatelessWidget {
  /// Creates a row showing icon, name, and today's time.
  const UsageAppTile({
    super.key,
    required this.entity,
    this.isActive = false,
    this.showDivider = true,
  });

  final AppUsageEntity entity;
  final bool isActive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: isActive ? AppTheme.primarySoft : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _IconBubble(iconBytes: entity.iconBytes, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GText(
                        entity.appName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      GText(
                        entity.packageName,
                        style: Theme.of(context).textTheme.bodySmall,
                        color: AppTheme.onSurfaceMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.onSurfaceMuted.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: GText(
                    formatUsageDuration(entity.todaySeconds),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    color: isActive ? AppTheme.surface : AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 72),
            child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
          ),
      ],
    );
  }
}
