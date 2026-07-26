import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/router/page_name.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_card.dart';
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
///
/// Layout follows Telegram Account / Settings: grey canvas, white rounded
/// cards, colorful rounded-square icons, blue section headers, pill CTAs.
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
                hasBatteryUnrestricted: false,
              ),
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // Intro caption under the app bar — Telegram “A few words…” style.
              GText(
                l10n.permissionsIntro,
                style: Theme.of(context).textTheme.bodySmall,
                color: AppTheme.onSurfaceMuted,
              ),
              GGap.m(),
              GCard(
                header: l10n.permissionsTitle,
                child: Column(
                  children: [
                    GSettingsTile(
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppTheme.iconBlue,
                      title: l10n.usagePermissionTitle,
                      subtitle: l10n.usagePermissionBody,
                      trailing: GPillBadge(
                        label: status.hasUsageAccess
                            ? l10n.permissionGranted
                            : l10n.permissionMissing,
                        tone: status.hasUsageAccess
                            ? GPillTone.success
                            : GPillTone.danger,
                      ),
                      onTap: () {
                        context
                            .read<UsageBloc>()
                            .add(const UsageEvent.requestUsagePermission());
                      },
                      showDivider: true,
                    ),
                    GSettingsTile(
                      icon: Icons.layers_rounded,
                      iconColor: AppTheme.iconOrange,
                      title: l10n.overlayPermissionTitle,
                      subtitle: l10n.overlayPermissionBody,
                      trailing: GPillBadge(
                        label: status.hasOverlayAccess
                            ? l10n.permissionGranted
                            : l10n.permissionMissing,
                        tone: status.hasOverlayAccess
                            ? GPillTone.success
                            : GPillTone.danger,
                      ),
                      onTap: () {
                        context
                            .read<UsageBloc>()
                            .add(const UsageEvent.requestOverlayPermission());
                      },
                      showDivider: true,
                    ),
                    GSettingsTile(
                      icon: Icons.battery_charging_full_rounded,
                      iconColor: AppTheme.iconGreen,
                      title: l10n.batteryPermissionTitle,
                      subtitle: l10n.batteryPermissionBody,
                      trailing: GPillBadge(
                        label: status.hasBatteryUnrestricted
                            ? l10n.permissionGranted
                            : l10n.permissionMissing,
                        tone: status.hasBatteryUnrestricted
                            ? GPillTone.success
                            : GPillTone.danger,
                      ),
                      onTap: () {
                        context.read<UsageBloc>().add(
                              const UsageEvent.requestBatteryUnrestricted(),
                            );
                      },
                    ),
                  ],
                ),
              ),
              GGap.s(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GText(
                  l10n.footerHintPermissions,
                  style: Theme.of(context).textTheme.bodySmall,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
              GGap.l(),
              // Explicit open actions — same as Telegram “Change >” affordances.
              GCard(
                child: Column(
                  children: [
                    GSettingsTile(
                      icon: Icons.open_in_new_rounded,
                      iconColor: AppTheme.iconTeal,
                      title: l10n.grantUsageAccess,
                      onTap: () {
                        context
                            .read<UsageBloc>()
                            .add(const UsageEvent.requestUsagePermission());
                      },
                      showDivider: true,
                    ),
                    GSettingsTile(
                      icon: Icons.open_in_new_rounded,
                      iconColor: AppTheme.iconPurple,
                      title: l10n.grantOverlayAccess,
                      onTap: () {
                        context
                            .read<UsageBloc>()
                            .add(const UsageEvent.requestOverlayPermission());
                      },
                      showDivider: true,
                    ),
                    GSettingsTile(
                      icon: Icons.open_in_new_rounded,
                      iconColor: AppTheme.iconRed,
                      title: l10n.grantBatteryUnrestricted,
                      onTap: () {
                        context.read<UsageBloc>().add(
                              const UsageEvent.requestBatteryUnrestricted(),
                            );
                      },
                    ),
                  ],
                ),
              ),
              GGap.l(),
              GButton(
                label: l10n.continueToHome,
                icon: Icons.arrow_forward_rounded,
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
                icon: Icons.refresh_rounded,
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
