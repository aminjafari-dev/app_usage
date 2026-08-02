import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Profile tab — simple identity card inside the main shell.
///
/// How to use: hosted inside [MainShellPage] via [IndexedStack].
class ProfilePage extends StatelessWidget {
  /// Creates the profile tab.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.navProfile,
      centerTitle: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          GGap.m(),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppTheme.primarySoft,
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
          ),
          GGap.m(),
          GText(
            l10n.appTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          GGap.s(),
          GText(
            l10n.profileSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            color: AppTheme.onSurfaceMuted,
            textAlign: TextAlign.center,
          ),
          GGap.l(),
          GCard(
            child: GSettingsTile(
              icon: Icons.info_outline_rounded,
              iconColor: AppTheme.iconTeal,
              title: l10n.appTitle,
              subtitle: 'v1.0.0',
            ),
          ),
        ],
      ),
    );
  }
}
