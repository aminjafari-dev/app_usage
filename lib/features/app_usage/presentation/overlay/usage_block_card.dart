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

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight;
          final maxW = constraints.maxWidth;
          // Stay within the real overlay window — during the first frames it
          // may still be badge-sized, so never force a height larger than that.
          final cardHeight = (maxH * 0.72).clamp(0.0, (maxH - 24).clamp(0.0, maxH));
          final cardWidth = (maxW - 32).clamp(0.0, maxW);
          final compact = cardHeight < 420;

          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0x66000000)),
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: ColoredBox(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.98),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight > 0 ? cardHeight : null,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          compact ? 24 : 40,
                          24,
                          compact ? 20 : 28,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: (cardHeight -
                                    (compact ? 44 : 68))
                                .clamp(0.0, double.infinity),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: compact ? 72 : 96,
                                height: compact ? 72 : 96,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.surface.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: AppLogo(
                                  iconBytes: iconBytes,
                                  size: compact ? 48 : 64,
                                ),
                              ),
                              compact ? GGap.m() : GGap.l(),
                              Icon(
                                Icons.block_rounded,
                                size: compact ? 28 : 36,
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
                                      fontSize: compact ? 18 : null,
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
                                      fontSize: compact ? 13 : null,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: compact ? 20 : 36),
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
            ],
          );
        },
      ),
    );
  }
}
