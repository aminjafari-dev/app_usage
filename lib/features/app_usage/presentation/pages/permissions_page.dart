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

/// One-permission-per-step onboarding for Usage, Overlay, and Battery access.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.permissions);
/// ```
///
/// Each step explains why the permission matters, then offers a single CTA to
/// open the system grant flow. Progress shows as `1/3`, `2/3`, `3/3`.
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
  static const int _totalSteps = 3;

  int _stepIndex = 0;
  bool _didAlignToMissing = false;

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

  bool _isStepGranted(PermissionsStatus status, int step) {
    return switch (step) {
      0 => status.hasUsageAccess,
      1 => status.hasOverlayAccess,
      2 => status.hasBatteryUnrestricted,
      _ => false,
    };
  }

  int _firstMissingStep(PermissionsStatus status) {
    for (var i = 0; i < _totalSteps; i++) {
      if (!_isStepGranted(status, i)) return i;
    }
    return _totalSteps - 1;
  }

  void _goHome() {
    Navigator.of(context).pushReplacementNamed(PageName.home);
  }

  void _onPermissionsUpdated(PermissionsStatus status) {
    if (!_didAlignToMissing) {
      _didAlignToMissing = true;
      // Fresh launch with everything already granted → skip straight home.
      if (status.isReady && !Navigator.of(context).canPop()) {
        _goHome();
        return;
      }
      final missing = _firstMissingStep(status);
      if (missing != _stepIndex) {
        setState(() => _stepIndex = missing);
      }
      return;
    }

    if (status.isReady) {
      _goHome();
      return;
    }

    // Advance past a step once the user grants it.
    if (_isStepGranted(status, _stepIndex) && _stepIndex < _totalSteps - 1) {
      setState(() => _stepIndex += 1);
    }
  }

  void _requestCurrentPermission() {
    final event = switch (_stepIndex) {
      0 => const UsageEvent.requestUsagePermission(),
      1 => const UsageEvent.requestOverlayPermission(),
      _ => const UsageEvent.requestBatteryUnrestricted(),
    };
    context.read<UsageBloc>().add(event);
  }

  void _showPrivacySheet(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusCard),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GText(
                l10n.learnMorePrivacy,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              GGap.m(),
              GText(
                l10n.footerHintPermissions,
                style: Theme.of(context).textTheme.bodyMedium,
                color: AppTheme.onSurfaceMuted,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPop = Navigator.of(context).canPop();

    return GScaffold(
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
          final step = _PermissionStepData.fromIndex(_stepIndex, l10n);
          final granted = _isStepGranted(status, _stepIndex);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    if (canPop)
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppTheme.onSurface,
                      )
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    _StepBadge(
                      label: l10n.permissionStep(
                        _stepIndex + 1,
                        _totalSteps,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      _PermissionHero(
                        icon: step.icon,
                        iconColor: step.iconColor,
                        softColor: step.softColor,
                      ),
                      GGap.xl(),
                      GText(
                        step.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      GGap.m(),
                      GText(
                        step.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                        color: AppTheme.onSurfaceMuted,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    GButton(
                      label: granted ? l10n.continueNext : l10n.grantAccess,
                      icon: granted
                          ? Icons.arrow_forward_rounded
                          : Icons.lock_open_rounded,
                      onPressed: () {
                        if (granted) {
                          if (_stepIndex >= _totalSteps - 1) {
                            if (status.isReady) {
                              _goHome();
                            }
                            return;
                          }
                          setState(() => _stepIndex += 1);
                          return;
                        }
                        _requestCurrentPermission();
                      },
                    ),
                    GGap.m(),
                    TextButton(
                      onPressed: () => _showPrivacySheet(l10n),
                      child: GText(
                        l10n.learnMorePrivacy,
                        style: Theme.of(context).textTheme.bodyMedium,
                        color: AppTheme.onSurfaceMuted,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Visual + copy for a single permission step.
class _PermissionStepData {
  const _PermissionStepData({
    required this.icon,
    required this.iconColor,
    required this.softColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final Color softColor;
  final String title;
  final String body;

  static _PermissionStepData fromIndex(int index, AppLocalizations l10n) {
    return switch (index) {
      0 => _PermissionStepData(
          icon: Icons.bar_chart_rounded,
          iconColor: AppTheme.iconBlue,
          softColor: AppTheme.primarySoft,
          title: l10n.usagePermissionTitle,
          body: l10n.usagePermissionBody,
        ),
      1 => _PermissionStepData(
          icon: Icons.layers_rounded,
          iconColor: AppTheme.iconOrange,
          softColor: AppTheme.iconOrange.withValues(alpha: 0.16),
          title: l10n.overlayPermissionTitle,
          body: l10n.overlayPermissionBody,
        ),
      _ => _PermissionStepData(
          icon: Icons.battery_charging_full_rounded,
          iconColor: AppTheme.iconGreen,
          softColor: AppTheme.iconGreen.withValues(alpha: 0.16),
          title: l10n.batteryPermissionTitle,
          body: l10n.batteryPermissionBody,
        ),
    };
  }
}

/// Circular `1/3` progress chip at the top of each step.
class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: GText(
        label,
        style: Theme.of(context).textTheme.labelMedium,
        color: AppTheme.primary,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Large soft circle with the permission glyph in the center.
class _PermissionHero extends StatelessWidget {
  const _PermissionHero({
    required this.icon,
    required this.iconColor,
    required this.softColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: softColor,
      ),
      child: Icon(icon, size: 72, color: iconColor),
    );
  }
}
