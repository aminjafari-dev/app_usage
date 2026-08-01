import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Fallback page for iOS and other non-Android platforms.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.unsupported);
/// ```
///
/// Empty-state composition matches the profile “No posts yet…” layout.
class UnsupportedPage extends StatelessWidget {
  /// Creates the unsupported platform message screen.
  const UnsupportedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.appTitle,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GGap.xl(),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                shape: BoxShape.circle,
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            GGap.l(),
            GCard(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                children: [
                  GText(
                    l10n.unsupportedTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  GGap.s(),
                  GText(
                    l10n.unsupportedMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                    color: AppTheme.onSurfaceMuted,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
