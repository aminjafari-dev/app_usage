import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Frosted dim that covers the screen behind a sheet or dialog.
///
/// [t] is the route animation (0 = clear, 1 = fully blurred).
class GBlurScrim extends StatelessWidget {
  /// Creates a frosted scrim. Pass [t] from an [AnimatedBuilder].
  const GBlurScrim({
    super.key,
    required this.t,
    this.child,
  });

  /// Blur / tint progress, typically `animation.value`.
  final double t;

  /// Content drawn on top of the frost (sheet, dialog, …).
  final Widget? child;

  static const double _sigma = 20;

  @override
  Widget build(BuildContext context) {
    final progress = t.clamp(0.0, 1.0);
    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _sigma * progress,
            sigmaY: _sigma * progress,
          ),
          child: ColoredBox(
            color: Colors.white.withValues(alpha: 0.2 * progress),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Opens [builder] as a bottom sheet with a blurred page behind it.
///
/// How to use:
/// ```dart
/// await showGBlurredBottomSheet(
///   context: context,
///   builder: (context) => const MySheet(),
/// );
/// ```
///
/// The sheet slides up on open, dismisses on scrim tap, and can be dragged
/// down to close (including when its body is a scroll view at the top).
Future<T?> showGBlurredBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, _, _) {
      return builder(dialogContext);
    },
    transitionBuilder: (dialogContext, animation, _, child) {
      return _GBlurredSheetScaffold(
        animation: animation,
        onDismiss: () => Navigator.of(dialogContext).maybePop(),
        child: child,
      );
    },
  );
}

/// Sheet chrome: frosted scrim, slide-in, and drag-to-dismiss.
class _GBlurredSheetScaffold extends StatefulWidget {
  const _GBlurredSheetScaffold({
    required this.animation,
    required this.onDismiss,
    required this.child,
  });

  final Animation<double> animation;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_GBlurredSheetScaffold> createState() => _GBlurredSheetScaffoldState();
}

class _GBlurredSheetScaffoldState extends State<_GBlurredSheetScaffold>
    with SingleTickerProviderStateMixin {
  static const double _dismissDistanceFraction = 0.28;
  static const double _dismissVelocity = 900;

  /// Pixels the sheet has been pulled down past its resting position.
  double _dragOffset = 0;

  /// Measured height of the sheet panel (for threshold + off-screen settle).
  double _sheetHeight = 0;

  AnimationController? _settleController;

  @override
  void dispose() {
    _settleController?.dispose();
    super.dispose();
  }

  void _onDragUpdate(double deltaDy) {
    if (deltaDy == 0) return;
    _settleController?.stop();
    setState(() {
      _dragOffset = (_dragOffset + deltaDy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(double velocityDy) {
    final height = _sheetHeight > 0 ? _sheetHeight : 320.0;
    final shouldClose = _dragOffset > height * _dismissDistanceFraction ||
        velocityDy > _dismissVelocity;

    if (shouldClose) {
      _animateDragTo(height, thenDismiss: true);
    } else {
      _animateDragTo(0);
    }
  }

  void _animateDragTo(double target, {bool thenDismiss = false}) {
    _settleController?.dispose();
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: thenDismiss ? 200 : 220),
    );
    final animation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(
        parent: controller,
        curve: thenDismiss ? Curves.easeInCubic : Curves.easeOutCubic,
      ),
    );
    animation.addListener(() {
      setState(() => _dragOffset = animation.value);
    });
    controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      if (thenDismiss) widget.onDismiss();
    });
    _settleController = controller;
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, _) {
        final entryT = Curves.easeOutCubic.transform(widget.animation.value);
        final dragT = _sheetHeight > 0
            ? (1 - (_dragOffset / _sheetHeight).clamp(0.0, 1.0))
            : 1.0;
        final scrimT = entryT * dragT;

        return GBlurScrim(
          t: scrimT,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: widget.onDismiss,
                behavior: HitTestBehavior.opaque,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionalTranslation(
                  translation: Offset(0, 1 - entryT),
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: Builder(
                      builder: (context) {
                        final media = MediaQuery.of(context);
                        final margin = EdgeInsets.fromLTRB(
                          12,
                          12,
                          12,
                          12 + media.padding.bottom,
                        );
                        return Padding(
                          padding: margin,
                          child: Material(
                            color: Colors.transparent,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    media.size.height - margin.vertical,
                              ),
                              child: _DragToDismissSheet(
                                onDragUpdate: _onDragUpdate,
                                onDragEnd: _onDragEnd,
                                onHeight: (h) {
                                  if (h > 0 && (h - _sheetHeight).abs() > 0.5) {
                                    _sheetHeight = h;
                                  }
                                },
                                child: widget.child,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pull-down dismiss that cooperates with nested vertical scroll views.
///
/// Uses a [Listener] (not a competing [GestureDetector]) so list scrolling
/// keeps working; sheet drag starts only when content is scrolled to the top
/// and the pointer moves downward.
class _DragToDismissSheet extends StatefulWidget {
  const _DragToDismissSheet({
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onHeight,
    required this.child,
  });

  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;
  final ValueChanged<double> onHeight;
  final Widget child;

  @override
  State<_DragToDismissSheet> createState() => _DragToDismissSheetState();
}

class _DragToDismissSheetState extends State<_DragToDismissSheet> {
  double _scrollPixels = 0;
  bool _draggingSheet = false;
  int? _activePointer;
  VelocityTracker? _velocityTracker;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          _scrollPixels = notification.metrics.pixels;
        }
        return false;
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          _activePointer = event.pointer;
          _draggingSheet = false;
          _velocityTracker = VelocityTracker.withKind(event.kind)
            ..addPosition(event.timeStamp, event.position);
        },
        onPointerMove: (event) {
          if (event.pointer != _activePointer) return;
          _velocityTracker?.addPosition(event.timeStamp, event.position);
          final dy = event.delta.dy;

          if (_draggingSheet) {
            widget.onDragUpdate(dy);
            return;
          }

          // At rest / no scrollable: downward move starts a dismiss drag.
          if (_scrollPixels <= 0.5 && dy > 0) {
            _draggingSheet = true;
            widget.onDragUpdate(dy);
          }
        },
        onPointerUp: (event) {
          if (event.pointer != _activePointer) return;
          _finishPointer();
        },
        onPointerCancel: (event) {
          if (event.pointer != _activePointer) return;
          _finishPointer();
        },
        child: _MeasureSize(
          onChange: widget.onHeight,
          child: widget.child,
        ),
      ),
    );
  }

  void _finishPointer() {
    if (_draggingSheet) {
      final velocity =
          _velocityTracker?.getVelocity().pixelsPerSecond.dy ?? 0;
      widget.onDragEnd(velocity);
    }
    _draggingSheet = false;
    _activePointer = null;
    _velocityTracker = null;
  }
}

/// Reports [child]'s layout height after each layout pass.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required Widget child,
  }) : super(child: child);

  final ValueChanged<double> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<double> onChange;
  double? _lastHeight;

  @override
  void performLayout() {
    super.performLayout();
    final h = child?.size.height ?? 0;
    if (_lastHeight != h) {
      _lastHeight = h;
      WidgetsBinding.instance.addPostFrameCallback((_) => onChange(h));
    }
  }
}

/// Opens a centered dialog with the same frosted backdrop as the sheets.
///
/// How to use:
/// ```dart
/// await showGBlurredDialog(
///   context: context,
///   builder: (context) => const MyDialog(),
/// );
/// ```
Future<T?> showGBlurredDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (dialogContext, _, _) {
      return builder(dialogContext);
    },
    transitionBuilder: (dialogContext, animation, _, child) {
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(animation.value);
          return GBlurScrim(
            t: t,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(dialogContext).maybePop(),
                  behavior: HitTestBehavior.opaque,
                ),
                Opacity(
                  opacity: t,
                  child: child,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
