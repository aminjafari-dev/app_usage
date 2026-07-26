import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/router/page_name.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_bloc.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_event.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_state.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Onboarding screen for Usage Access + Overlay permissions.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.permissions);
/// ```
class PermissionsPage extends StatelessWidget {
  /// Creates the permissions page with its own [UsageBloc] instance.
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          locator<UsageBloc>()..add(const UsageEvent.refreshPermissions()),
      child: const _PermissionsView(),
    );
  }
}

class _PermissionsView extends StatelessWidget {
  const _PermissionsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.permissionsTitle,
      showBackButton: true,
      body: BlocBuilder<UsageBloc, UsageState>(
        builder: (context, state) {
          final status = switch (state.permissions) {
            PermissionsOpCompleted(:final status) => status,
            _ => const PermissionsStatus(
                hasUsageAccess: false,
                hasOverlayAccess: false,
              ),
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PermissionCard(
                title: l10n.usagePermissionTitle,
                body: l10n.usagePermissionBody,
                granted: status.hasUsageAccess,
                actionLabel: l10n.grantUsageAccess,
                onPressed: () {
                  context
                      .read<UsageBloc>()
                      .add(const UsageEvent.requestUsagePermission());
                },
              ),
              GGap.m(),
              _PermissionCard(
                title: l10n.overlayPermissionTitle,
                body: l10n.overlayPermissionBody,
                granted: status.hasOverlayAccess,
                actionLabel: l10n.grantOverlayAccess,
                onPressed: () {
                  context
                      .read<UsageBloc>()
                      .add(const UsageEvent.requestOverlayPermission());
                },
              ),
              GGap.l(),
              GButton(
                label: l10n.continueToHome,
                onPressed: status.isReady
                    ? () {
                        Navigator.of(context).pushReplacementNamed(
                          PageName.home,
                        );
                      }
                    : null,
              ),
              GGap.s(),
              GOutlinedButton(
                label: l10n.refresh,
                onPressed: () {
                  context
                      .read<UsageBloc>()
                      .add(const UsageEvent.refreshPermissions());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Single permission block with status chip + CTA.
class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.body,
    required this.granted,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final bool granted;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GText(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: granted
                      ? AppTheme.success.withValues(alpha: 0.12)
                      : AppTheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GText(
                  granted ? l10n.permissionGranted : l10n.permissionMissing,
                  style: Theme.of(context).textTheme.bodySmall,
                  color: granted ? AppTheme.success : AppTheme.error,
                ),
              ),
            ],
          ),
          GGap.s(),
          GTextMuted(body),
          GGap.m(),
          // Still allow opening settings even when already granted (re-check).
          GOutlinedButton(label: actionLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}
