import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:app_usage/core/settings/usage_coach.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_blur_sheet.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Opens the reusable over-limit coach card and returns when dismissed.
///
/// How to use:
/// ```dart
/// await showUsageCoachCard(
///   context,
///   decision: CoachDecision(
///     shouldShow: true,
///     minutesOver: 12,
///     snoozeMinutes: 5,
///     allowMuteToday: true,
///   ),
/// );
/// ```
Future<void> showUsageCoachCard(
  BuildContext context, {
  required CoachDecision decision,
  List<int>? iconBytes,
}) {
  return showGBlurredDialog<void>(
    context: context,
    builder: (dialogContext) {
      void dismiss() => Navigator.of(dialogContext).pop();
      return UsageCoachCard(
        decision: decision,
        iconBytes: iconBytes,
        onPause: dismiss,
        onSnooze: dismiss,
      );
    },
  );
}

/// Center coach reminder shown over other apps when a daily limit is hit.
///
/// How to use: mounted full-screen inside [OverlayApp] while coach mode is on.
class UsageCoachCard extends StatelessWidget {
  /// Creates the coach card.
  const UsageCoachCard({
    super.key,
    required this.decision,
    this.iconBytes,
    required this.onPause,
    required this.onSnooze,
    this.blurBackground = false,
  });

  final CoachDecision decision;
  final List<int>? iconBytes;
  final VoidCallback onPause;
  final VoidCallback onSnooze;

  /// Frosts the overlay window behind the card when shown over another app.
  /// Settings preview already wraps this widget in [showGBlurredDialog].
  final bool blurBackground;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final card = SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Material(
              color: AppTheme.surface,
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AppIcon(iconBytes: iconBytes, size: 56),
                    GGap.m(),
                    GText(
                      l10n.coachOverLimitSubtitle(decision.minutesOver),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    GGap.l(),
                    Row(
                      children: [
                        Expanded(
                          child: GButton(
                            label: l10n.coachPauseButton,
                            icon: Icons.spa_rounded,
                            onPressed: onPause,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GOutlinedButton(
                            label: l10n.coachSnoozeButton(decision.snoozeMinutes),
                            icon: Icons.timelapse_rounded,
                            onPressed: onSnooze,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!blurBackground) return card;

    return GBlurScrim(t: 1, child: card);
  }
}

/// Resolves a rotating coach [id] into the matching localized quote.
String coachMessageFor(AppLocalizations l10n, String id) {
  return switch (id) {
    'goal' => l10n.coachMessageGoal,
    'appsChange' => l10n.coachMessageAppsChange,
    'pause' => l10n.coachMessagePause,
    'choice' => l10n.coachMessageChoice,
    'protect' => l10n.coachMessageProtect,
    _ => l10n.coachMessageBoss,
  };
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({this.iconBytes, required this.size});

  final List<int>? iconBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    final radius = size * 0.28;

    Widget child;
    if (bytes != null && bytes.isNotEmpty) {
      child = Image.memory(
        Uint8List.fromList(bytes),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: AppTheme.primarySoft,
      child: Icon(
        Icons.timer_outlined,
        size: size * 0.5,
        color: AppTheme.primary,
      ),
    );
  }
}
