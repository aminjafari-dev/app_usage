import 'dart:ui';

import 'package:flutter/material.dart';

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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionalTranslation(
                    translation: Offset(0, 1 - t),
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
                                maxHeight: media.size.height - margin.vertical,
                              ),
                              child: child,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
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
