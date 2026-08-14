import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:app_usage/core/settings/badge_appearance_cubit.dart';
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
///
/// When [overLimit] is true, the pill grows sideways (height stays put) to
/// reveal an idle alert. Tapping it opens [quote] in a bubble under the badge.
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
    this.overLimit = false,
    this.quoteOpen = false,
    this.quote,
    this.closeLabel,
    this.alertLabel,
    this.onAlertTap,
    this.onQuoteClose,
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

  /// When true, the pill grows sideways and shows the idle alert glyph.
  final bool overLimit;

  /// When true, the quote bubble is shown directly under the pill.
  final bool quoteOpen;

  /// Supportive quote drawn in the center of the under-badge bubble.
  final String? quote;

  /// Tooltip / semantics for the tiny close control on the quote bubble.
  final String? closeLabel;

  /// Semantics label for the over-limit alert glyph.
  final String? alertLabel;

  /// Opens the quote bubble. Ignored while [quoteOpen] is already true.
  final VoidCallback? onAlertTap;

  /// Hides the quote bubble without removing the alert glyph.
  final VoidCallback? onQuoteClose;

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
    final scale = widget.sizeScale.clamp(
          BadgeAppearance.minSizeScale,
          BadgeAppearance.maxSizeScale,
        ) *
        sizeBoost;
    final iconSize = 22 * scale;
    final fontSize = 13 * scale;
    final hPad = 2 * scale;
    final vPad = 2 * scale;
    final gap = 4 * scale;
    final chipHeight = iconSize + vPad * 2;
    final chipRadius = chipHeight / 2;
    // Hold the alert until the open-app intro has settled so the two width
    // animations do not fight (circle → duration, then duration → alert).
    final showAlert =
        widget.overLimit && (!widget.playIntro || _introSettled);
    final quote = widget.quote;
    final showQuote = widget.quoteOpen && quote != null && quote.isNotEmpty;

    // Top-left during intro so the logo stays put while the pill grows right;
    // top-center for static previews.
    return Align(
      alignment: widget.playIntro ? Alignment.topLeft : Alignment.topCenter,
      child: Opacity(
        opacity: widget.opacity.clamp(0.3, 1.0),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: vPad,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.overlayChipFill,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  // Logo anchored left; trailing content clips open to the right
                  // so the chip starts as a circle and grows into the duration pill.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ChipAppLogo(
                        iconBytes: widget.iconBytes,
                        size: iconSize,
                      ),
                      // widthFactor reveals the duration; heightFactor: 1
                      // shrink-wraps so this slot does not inherit overlay height.
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: expand.clamp(0.0, 1.0),
                          heightFactor: 1,
                          child: SizedBox(
                            height: iconSize,
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
                      ),
                      if (widget.overLimit)
                        _RevealSlot(
                          visible: showAlert,
                          axis: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: gap),
                              _LimitAlertIcon(
                                size: iconSize,
                                semanticLabel: widget.alertLabel,
                                onTap: widget.onAlertTap,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _RevealSlot(
                visible: showQuote,
                axis: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.only(top: 4 * scale),
                  child: _QuoteBubble(
                    quote: quote ?? '',
                    radius: chipRadius,
                    scale: scale,
                    closeLabel: widget.closeLabel,
                    onClose: widget.onQuoteClose,
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

/// Clips [child] open on [axis] so the badge can grow in width (alert) or
/// height (quote) without changing the other dimension.
class _RevealSlot extends StatefulWidget {
  const _RevealSlot({
    required this.visible,
    required this.axis,
    required this.child,
  });

  final bool visible;
  final Axis axis;
  final Widget child;

  @override
  State<_RevealSlot> createState() => _RevealSlotState();
}

class _RevealSlotState extends State<_RevealSlot>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 420);

  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _RevealSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final factor = _t.value.clamp(0.0, 1.0);
        return IgnorePointer(
          ignoring: factor == 0,
          child: _CollapseIntrinsicWidth(
            collapse: widget.axis == Axis.vertical && factor == 0,
            child: ClipRect(
              child: Align(
                alignment: widget.axis == Axis.horizontal
                    ? Alignment.centerLeft
                    : Alignment.topCenter,
                widthFactor: widget.axis == Axis.horizontal ? factor : 1,
                heightFactor: widget.axis == Axis.vertical ? factor : 1,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Drops width from [IntrinsicWidth] while a vertical reveal is fully closed.
class _CollapseIntrinsicWidth extends SingleChildRenderObjectWidget {
  const _CollapseIntrinsicWidth({
    required this.collapse,
    required super.child,
  });

  final bool collapse;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCollapseIntrinsicWidth(collapse: collapse);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderCollapseIntrinsicWidth renderObject,
  ) {
    renderObject.collapse = collapse;
  }
}

class _RenderCollapseIntrinsicWidth extends RenderProxyBox {
  _RenderCollapseIntrinsicWidth({required bool collapse}) : _collapse = collapse;

  bool _collapse;
  bool get collapse => _collapse;
  set collapse(bool value) {
    if (_collapse == value) return;
    _collapse = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _collapse ? 0 : super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _collapse ? 0 : super.computeMaxIntrinsicWidth(height);
  }
}

/// Minimalist over-limit glyph that sips / wobbles in place every 2 seconds.
class _LimitAlertIcon extends StatefulWidget {
  const _LimitAlertIcon({
    required this.size,
    this.semanticLabel,
    this.onTap,
  });

  final double size;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  State<_LimitAlertIcon> createState() => _LimitAlertIconState();
}

class _LimitAlertIconState extends State<_LimitAlertIcon>
    with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(seconds: 2);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycle)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.error_outline_rounded,
      size: widget.size,
      color: AppTheme.overlayChipAlert,
    );

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final motion = _sip(_controller.value);
            return Transform.translate(
              offset: Offset(motion.dx, motion.dy),
              child: Transform.rotate(
                angle: motion.angle,
                child: child,
              ),
            );
          },
          child: icon,
        ),
      ),
    );
  }

  /// First ~800ms of each 2s cycle: dip + lean like a tiny sip, then rest.
  ({double dx, double dy, double angle}) _sip(double t) {
    const sipEnd = 0.4;
    if (t >= sipEnd) {
      return (dx: 0.0, dy: 0.0, angle: 0.0);
    }
    final u = t / sipEnd;
    final double p;
    if (u < 0.35) {
      p = Curves.easeInOut.transform(u / 0.35);
    } else if (u < 0.55) {
      p = 1;
    } else {
      p = 1 - Curves.easeInOut.transform((u - 0.55) / 0.45);
    }
    return (
      dx: 1.2 * p,
      dy: 2.4 * p,
      angle: 0.22 * p,
    );
  }
}

/// Padding, type, and max width for the over-limit quote bubble.
///
/// How to use: [measure] from the overlay isolate before resizing the native
/// window, so longer quotes get a taller / wider overlay instead of clipping.
class UsageQuoteBubbleLayout {
  /// Creates layout numbers for a badge [scale] (size × intro boost).
  const UsageQuoteBubbleLayout(this.scale);

  /// Same scale the painted badge is using.
  final double scale;

  /// Widest the bubble may grow before wrapping to another line.
  double get maxWidth => 260 * scale;

  EdgeInsets get padding => EdgeInsets.fromLTRB(
        12 * scale,
        14 * scale,
        18 * scale,
        12 * scale,
      );

  TextStyle get textStyle => TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w500,
        height: 1.35,
        fontStyle: FontStyle.italic,
      );

  /// Painted size of the bubble for [quote] in [direction].
  Size measure(String quote, TextDirection direction) {
    final maxTextWidth =
        (maxWidth - padding.horizontal).clamp(1.0, double.infinity);
    final painter = TextPainter(
      text: TextSpan(text: quote, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: direction,
    );
    try {
      painter.layout(maxWidth: maxTextWidth);
      return Size(
        (painter.width + padding.horizontal).clamp(0.0, maxWidth),
        painter.height + padding.vertical,
      );
    } finally {
      painter.dispose();
    }
  }
}

/// Quote panel docked under the badge, sharing the badge's corner radius.
class _QuoteBubble extends StatelessWidget {
  const _QuoteBubble({
    required this.quote,
    required this.radius,
    required this.scale,
    this.closeLabel,
    this.onClose,
  });

  final String quote;
  final double radius;
  final double scale;
  final String? closeLabel;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final layout = UsageQuoteBubbleLayout(scale);
    final closeSize = 16 * scale;
    final closeIcon = 11 * scale;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: layout.maxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.overlayChipFill,
          borderRadius: BorderRadius.circular(radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: layout.padding,
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: layout.textStyle.copyWith(
                  color: AppTheme.overlayChipText,
                ),
              ),
            ),
            PositionedDirectional(
              top: 3 * scale,
              end: 3 * scale,
              child: Semantics(
                button: true,
                label: closeLabel,
                child: GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: closeSize.clamp(22.0, 28.0),
                    height: closeSize.clamp(22.0, 28.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: closeIcon,
                      color: AppTheme.overlayChipText.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny circular launcher icon for the timer chip (fallback: sage clock).
///
/// Android PackageManager icons are often already masked as a rounded square
/// (adaptive icon). We clip to a circle and zoom slightly so the silhouette is
/// a true circle, not a squircle sitting inside an oval clip.
class _ChipAppLogo extends StatelessWidget {
  const _ChipAppLogo({this.iconBytes, required this.size});

  final List<int>? iconBytes;
  final double size;

  /// Zooms past Android's rounded-square mask so [ClipOval] cuts a real circle.
  static const double _circleCropScale = 1.2;

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

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Transform.scale(
          scale: _circleCropScale,
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
                 GText(
                    formatUsageDuration(entity.todaySeconds),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    color: isActive ? AppTheme.surface : AppTheme.onSurfaceMuted,
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
