import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/router/page_name.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_bloc.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_event.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_state.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Single-page permission checklist for Usage, Overlay, and Battery access.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.permissions);
/// ```
///
/// Each row has an Allow CTA (or a green check when granted). Once every
/// permission is ready, the bottom arrow continues into the main shell.
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

class _PermissionsView extends StatefulWidget {
  const _PermissionsView();

  @override
  State<_PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends State<_PermissionsView>
    with WidgetsBindingObserver {
  bool _didHandleInitial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<UsageBloc>().add(const UsageEvent.refreshPermissions());
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacementNamed(PageName.home);
  }

  void _onPermissionsUpdated(PermissionsStatus status) {
    if (!_didHandleInitial) {
      _didHandleInitial = true;
      // Fresh launch with everything already granted → skip straight home.
      if (status.isReady && !Navigator.of(context).canPop()) {
        _goHome();
      }
      return;
    }

    if (status.isReady && !Navigator.of(context).canPop()) {
      _goHome();
    }
  }

  void _request(UsageEvent event) {
    context.read<UsageBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPop = Navigator.of(context).canPop();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppTheme.backgroundDark : AppTheme.surface;

    return GScaffold(
      backgroundColor: pageBg,
      body: BlocConsumer<UsageBloc, UsageState>(
        listenWhen: (previous, current) =>
            previous.permissions != current.permissions,
        listener: (context, state) {
          final status = switch (state.permissions) {
            PermissionsOpCompleted(:final status) => status,
            _ => null,
          };
          if (status != null) {
            _onPermissionsUpdated(status);
          }
        },
        builder: (context, state) {
          final status = switch (state.permissions) {
            PermissionsOpCompleted(:final status) => status,
            _ => const PermissionsStatus(
                hasUsageAccess: false,
                hasOverlayAccess: false,
                hasBatteryUnrestricted: false,
              ),
          };

          final rows = [
            _PermissionRowData(
              icon: Icons.bar_chart_rounded,
              label: l10n.usagePermissionTitle,
              granted: status.hasUsageAccess,
              onAllow: () =>
                  _request(const UsageEvent.requestUsagePermission()),
            ),
            _PermissionRowData(
              icon: Icons.layers_outlined,
              label: l10n.overlayPermissionTitle,
              granted: status.hasOverlayAccess,
              onAllow: () =>
                  _request(const UsageEvent.requestOverlayPermission()),
            ),
            _PermissionRowData(
              icon: Icons.battery_charging_full_rounded,
              label: l10n.batteryPermissionTitle,
              granted: status.hasBatteryUnrestricted,
              onAllow: () =>
                  _request(const UsageEvent.requestBatteryUnrestricted()),
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: canPop
                      ? IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppTheme.onSurfaceOf(context),
                        )
                      : const SizedBox(height: 48),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  children: [
                    GText(
                      l10n.permissionsTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    GGap.s(),
                    GText(
                      l10n.permissionsSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                      color: AppTheme.onSurfaceMuted,
                    ),
                    GGap.xl(),
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppTheme.dividerOf(context),
                        ),
                      _PermissionRow(data: rows[i], allowLabel: l10n.permissionAllow),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                  child: Row(
                    children: [
                      const Spacer(),
                      _ContinueFab(
                        enabled: status.isReady,
                        onPressed: status.isReady
                            ? () {
                                if (canPop) {
                                  Navigator.of(context).maybePop();
                                } else {
                                  _goHome();
                                }
                              }
                            : null,
                      ),
                    ],
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

class _PermissionRowData {
  const _PermissionRowData({
    required this.icon,
    required this.label,
    required this.granted,
    required this.onAllow,
  });

  final IconData icon;
  final String label;
  final bool granted;
  final VoidCallback onAllow;
}

/// Icon + label + Allow / check action for one Android permission.
class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.data,
    required this.allowLabel,
  });

  final _PermissionRowData data;
  final String allowLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Icon(
            data.icon,
            size: 26,
            color: AppTheme.onSurfaceOf(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GText(
              data.label,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          if (data.granted)
            const _GrantedChip()
          else
            _AllowChip(label: allowLabel, onPressed: data.onAllow),
        ],
      ),
    );
  }
}

/// Compact primary pill used to open the system grant screen.
class _AllowChip extends StatelessWidget {
  const _AllowChip({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.primaryButtonShadow,
      ),
      child: Material(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: GText(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
              color: AppTheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft green check shown once a permission is already granted.
class _GrantedChip extends StatelessWidget {
  const _GrantedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.success,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AppTheme.surface,
        size: 22,
      ),
    );
  }
}

/// Circular continue control — enabled only when every permission is ready.
class _ContinueFab extends StatelessWidget {
  const _ContinueFab({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = enabled
        ? AppTheme.primary
        : AppTheme.onSurfaceMuted.withValues(alpha: 0.28);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: enabled ? AppTheme.primaryButtonShadow : null,
      ),
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.surface,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
