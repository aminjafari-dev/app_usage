import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locale/locale_cubit.dart';
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
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Home dashboard: start/stop live counter + today's usage list.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.home);
/// ```
class HomePage extends StatelessWidget {
  /// Creates the home page; BLoC is provided internally via get_it.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<UsageBloc>()..add(const UsageEvent.started()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.homeTitle,
      actions: [
        IconButton(
          tooltip: l10n.refresh,
          onPressed: () {
            context.read<UsageBloc>().add(const UsageEvent.refreshUsage());
            context
                .read<UsageBloc>()
                .add(const UsageEvent.refreshPermissions());
          },
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: l10n.switchLanguage,
          onPressed: () => context.read<LocaleCubit>().toggle(),
          icon: const Icon(Icons.language),
        ),
      ],
      body: BlocConsumer<UsageBloc, UsageState>(
        listener: (context, state) {
          // Surface tracking errors as snackbars.
          if (state.tracking case TrackingOpError(:final message)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          final permissionsReady = switch (state.permissions) {
            PermissionsOpCompleted(:final status) => status.isReady,
            _ => false,
          };
          final isTracking = switch (state.tracking) {
            TrackingOpCompleted(:final isTracking) => isTracking,
            _ => false,
          };
          final trackingLoading = state.tracking is TrackingOpLoading;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UsageBloc>().add(const UsageEvent.refreshUsage());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!permissionsReady) ...[
                  _PermissionsBanner(
                    onOpen: () {
                      Navigator.of(context).pushNamed(PageName.permissions);
                    },
                  ),
                  GGap.m(),
                ],
                _TrackingCard(
                  isTracking: isTracking,
                  isLoading: trackingLoading,
                  currentApp: state.currentApp,
                  onToggle: () {
                    // Block start when permissions are incomplete.
                    if (!isTracking && !permissionsReady) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.permissionsRequired)),
                      );
                      Navigator.of(context).pushNamed(PageName.permissions);
                      return;
                    }
                    context.read<UsageBloc>().add(
                          isTracking
                              ? const UsageEvent.stopTracking()
                              : const UsageEvent.startTracking(),
                        );
                  },
                ),
                GGap.l(),
                GText(
                  l10n.homeTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                GGap.m(),
                ...switch (state.todayUsage) {
                  TodayUsageOpInitial() => [const SizedBox.shrink()],
                  TodayUsageOpLoading() => [
                      const Center(child: CircularProgressIndicator()),
                    ],
                  TodayUsageOpCompleted(:final apps) => apps.isEmpty
                      ? [GTextMuted(l10n.noUsageYet)]
                      : [
                          for (final app in apps)
                            UsageAppTile(
                              entity: app,
                              isActive: state.currentApp?.packageName ==
                                  app.packageName,
                            ),
                        ],
                  TodayUsageOpError(:final message) => [
                      GText(message, color: AppTheme.error),
                    ],
                },
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Banner that nudges the user to finish Android permission setup.
class _PermissionsBanner extends StatelessWidget {
  const _PermissionsBanner({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GText(
            l10n.permissionsRequired,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          GGap.s(),
          GButton(label: l10n.permissionsTitle, onPressed: onOpen),
        ],
      ),
    );
  }
}

/// Card with glass preview + start/stop CTA.
class _TrackingCard extends StatelessWidget {
  const _TrackingCard({
    required this.isTracking,
    required this.isLoading,
    required this.currentApp,
    required this.onToggle,
  });

  final bool isTracking;
  final bool isLoading;
  final AppUsageEntity? currentApp;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = currentApp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GText(
            isTracking ? l10n.trackingActive : l10n.trackingInactive,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          GGap.m(),
          if (preview != null) ...[
            GTextMuted(l10n.currentApp),
            GGap.s(),
            UsageGlassCounter(
              appName: preview.appName,
              todaySeconds: preview.todaySeconds,
              iconBytes: preview.iconBytes,
              compact: false,
            ),
            GGap.m(),
          ] else
            UsageGlassCounter(
              appName: l10n.appTitle,
              todaySeconds: 0,
              compact: false,
            ),
          GGap.m(),
          GButton(
            label: isTracking ? l10n.stopTracking : l10n.startTracking,
            onPressed: onToggle,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
