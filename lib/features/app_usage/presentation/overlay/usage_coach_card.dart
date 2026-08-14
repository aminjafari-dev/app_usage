import 'package:flutter/material.dart';

import 'package:app_usage/core/settings/usage_coach.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_blur_sheet.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/app_logo.dart';
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
  // Bottom sheet already applies the 12 dp edge insets.
  return showGBlurredBottomSheet<void>(
    context: context,
    builder: (dialogContext) {
      void dismiss() => Navigator.of(dialogContext).pop();
      return UsageCoachCard(
        decision: decision,
        iconBytes: iconBytes,
        onPause: dismiss,
        onSnooze: dismiss,
        applyScreenInsets: false,
      );
    },
  );
}

/// Bottom coach reminder shown over other apps when a daily limit is hit.
///
/// How to use: mounted full-screen inside [OverlayApp] while coach mode is on.
/// The card spans the screen width and sits at the bottom with a 12 dp inset
/// from each edge (plus the system bottom safe area).
class UsageCoachCard extends StatelessWidget {
  /// Creates the coach card.
  const UsageCoachCard({
    super.key,
    required this.decision,
    this.iconBytes,
    required this.onPause,
    required this.onSnooze,
    this.blurBackground = false,
    this.applyScreenInsets = true,
  });

  /// Inset from each edge of the phone screen.
  static const double screenMargin = 12;

  final CoachDecision decision;
  final List<int>? iconBytes;
  final VoidCallback onPause;
  final VoidCallback onSnooze;

  /// Kept for overlay call sites; the backdrop is always transparent so no
  /// full-screen rectangle is painted behind the card.
  final bool blurBackground;

  /// When false, the card fills its parent width and skips the outer 12 dp
  /// insets (e.g. [showGBlurredBottomSheet] already pads the sheet).
  final bool applyScreenInsets;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final card = Material(
      color: AppTheme.surface,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(iconBytes: iconBytes, size: 56),
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
                    onPressed: onPause,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GOutlinedButton(
                    label: l10n.coachSnoozeButton(decision.snoozeMinutes),
                    onPressed: onSnooze,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final fullWidthCard = SizedBox(width: double.infinity, child: card);

    if (!applyScreenInsets) {
      return fullWidthCard;
    }

    // Expand so Align can pin the card to the true bottom of the overlay.
    return SizedBox.expand(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenMargin,
            screenMargin,
            screenMargin,
            screenMargin + bottomInset,
          ),
          child: fullWidthCard,
        ),
      ),
    );
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
