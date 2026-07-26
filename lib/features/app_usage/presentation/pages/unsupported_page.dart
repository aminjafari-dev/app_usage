import 'package:flutter/material.dart';

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
class UnsupportedPage extends StatelessWidget {
  /// Creates the unsupported platform message screen.
  const UnsupportedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.unsupportedTitle,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GText(
              l10n.unsupportedTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            GGap.m(),
            GTextMuted(l10n.unsupportedMessage),
          ],
        ),
      ),
    );
  }
}
