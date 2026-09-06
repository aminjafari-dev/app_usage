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

  final String appName;
  final List<int>? iconBytes;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppTheme.backgroundDark.withValues(alpha: 0.94),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onSurfaceDark,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              GGap.s(),
              GText(
                l10n.blockSubtitle(appName),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceMuted,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
