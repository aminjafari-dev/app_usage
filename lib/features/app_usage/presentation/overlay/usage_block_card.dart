import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/app_logo.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Full-screen hard block shown over a blocked foreground app.
///
/// How to use: mounted inside [OverlayApp] after the native overlay window is
/// expanded to cover the screen. Touches are consumed by the overlay so the
/// blocked app cannot be used until the user leaves.
class UsageBlockCard extends StatelessWidget {
  /// Creates the block dialog.
  const UsageBlockCard({
    super.key,
    required this.appName,
    this.iconBytes,
    required this.onLeave,
  });

  /// Corner radius for the curved dialog edges.
  static const double cornerRadius = 32;

  final String appName;
  final List<int>? iconBytes;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    // Nearly full-screen card so curves stay visible with a thin inset —
    // no elevation/shadow that would paint a rectangular halo.
    final cardHeight = size.height - padding.vertical - 24;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft full-screen dim (blocks taps). Flat color — no card plate.
          const ColoredBox(color: Color(0x66000000)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: ColoredBox(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.98),
                    child: SizedBox(
                      width: double.infinity,
                      height: cardHeight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppTheme.surface.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: AppLogo(iconBytes: iconBytes, size: 64),
                            ),
                            GGap.l(),
                            Icon(
                              Icons.block_rounded,
                              size: 36,
                              color: AppTheme.error.withValues(alpha: 0.95),
                            ),
                            GGap.m(),
                            GText(
                              l10n.blockTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.onSurfaceDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            GGap.s(),
                            GText(
                              l10n.blockSubtitle(appName),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.onSurfaceMuted,
                                    height: 1.4,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(flex: 3),
                            GButton(
                              label: l10n.blockLeaveButton,
                              icon: Icons.home_rounded,
                              onPressed: onLeave,
                            ),
                            GGap.s(),
                            GText(
                              l10n.blockHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.onSurfaceMuted,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
