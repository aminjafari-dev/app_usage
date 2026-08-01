import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locale/locale_cubit.dart';
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
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Home dashboard: start/stop live counter + today's usage list.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.home);
/// ```
///
/// Layout follows the shared profile design: soft grey canvas, 32px white
/// cards, quick-action tiles, capsule CTAs, and a compact type scale.
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
      title: l10n.appTitle,
      actions: [
        IconButton(
          tooltip: l10n.refresh,
          onPressed: () {
            context.read<UsageBloc>().add(const UsageEvent.refreshUsage());
            context
                .read<UsageBloc>()
                .add(const UsageEvent.refreshPermissions());
          },
          icon: const Icon(Icons.search_rounded, size: 22),
        ),
        IconButton(
          tooltip: l10n.switchLanguage,
          onPressed: () => context.read<LocaleCubit>().toggle(),
          icon: const Icon(Icons.more_vert_rounded, size: 22),
        ),
      ],
      floatingActionButton: BlocBuilder<UsageBloc, UsageState>(
        builder: (context, state) {
          final isTracking = switch (state.tracking) {
            TrackingOpCompleted(:final isTracking) => isTracking,
            _ => false,
          };
          final trackingLoading = state.tracking is TrackingOpLoading;
          final permissionsReady = switch (state.permissions) {
            PermissionsOpCompleted(:final status) => status.isReady,
            _ => false,
          };

          return FloatingActionButton(
            onPressed: trackingLoading
                ? null
                : () {
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
            child: trackingLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.surface,
                    ),
                  )
                : Icon(
                    isTracking
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
          );
        },
      ),
      body: BlocConsumer<UsageBloc, UsageState>(
        listener: (context, state) {
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
            color: AppTheme.primary,
            onRefresh: () async {
              context.read<UsageBloc>().add(const UsageEvent.refreshUsage());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _ProfileHeader(
                  isTracking: isTracking,
                  currentApp: state.currentApp,
                ),
                GGap.l(),
                // Quick actions — 32px white tiles like the profile design.
                Row(
                  children: [
                    GQuickAction(
                      icon: Icons.refresh_rounded,
                      label: l10n.quickRefresh,
                      onTap: () {
                        context
                            .read<UsageBloc>()
                            .add(const UsageEvent.refreshUsage());
                      },
                    ),
                    const SizedBox(width: 12),
                    GQuickAction(
                      icon: Icons.language_rounded,
                      label: l10n.quickLanguage,
                      onTap: () => context.read<LocaleCubit>().toggle(),
                    ),
                    const SizedBox(width: 12),
                    GQuickAction(
                      icon: Icons.shield_outlined,
                      label: l10n.quickPermissions,
                      onTap: () {
                        Navigator.of(context).pushNamed(PageName.permissions);
                      },
                    ),
                  ],
                ),
                GGap.l(),
                if (!permissionsReady) ...[
                  _PermissionsBanner(
                    onOpen: () {
                      Navigator.of(context).pushNamed(PageName.permissions);
                    },
                  ),
                  GGap.l(),
                ],
                _TrackingCard(
                  isTracking: isTracking,
                  isLoading: trackingLoading,
                  currentApp: state.currentApp,
                  onToggle: () {
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
                ...switch (state.todayUsage) {
                  TodayUsageOpInitial() => [const SizedBox.shrink()],
                  TodayUsageOpLoading() => [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  TodayUsageOpCompleted(:final apps) => [
                      _TodayUsageCard(
                        apps: apps,
                        currentPackage: state.currentApp?.packageName,
                      ),
                    ],
                  TodayUsageOpError(:final message) => [
                      GCard(
                        padding: const EdgeInsets.all(20),
                        child: GText(message, color: AppTheme.error),
                      ),
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

/// Top identity block — large avatar, name, online/offline status.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isTracking,
    required this.currentApp,
  });

  final bool isTracking;
  final AppUsageEntity? currentApp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = currentApp;
    final iconBytes = preview?.iconBytes;

    return Column(
      children: [
        GGap.s(),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primarySoft,
                border: Border.all(color: AppTheme.surface, width: 3),
                boxShadow: AppTheme.cardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: iconBytes != null
                  ? Image.memory(
                      Uint8List.fromList(iconBytes),
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.hourglass_top_rounded,
                      size: 40,
                      color: AppTheme.primary,
                    ),
            ),
            // Small circular status badge on the avatar corner.
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 2),
              ),
              child: Icon(
                isTracking
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: AppTheme.surface,
                size: 14,
              ),
            ),
          ],
        ),
        GGap.m(),
        GText(
          preview?.appName ?? l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        GGap.xs(),
        GText(
          isTracking ? l10n.statusOnline : l10n.statusOffline,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          color: isTracking ? AppTheme.primary : AppTheme.onSurfaceMuted,
          textAlign: TextAlign.center,
        ),
      ],
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
    return GCard(
      child: GSettingsTile(
        icon: Icons.lock_open_rounded,
        iconColor: AppTheme.iconOrange,
        title: l10n.permissionsRequired,
        subtitle: l10n.permissionsRequiredHint,
        trailing: GText(
          l10n.openPermissions,
          style: Theme.of(context).textTheme.labelMedium,
          color: AppTheme.primary,
        ),
        onTap: onOpen,
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

    return GCard(
      header: l10n.trackingSectionHeader,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GText(
            isTracking ? l10n.trackingActive : l10n.trackingInactive,
            style: Theme.of(context).textTheme.bodySmall,
            color: AppTheme.onSurfaceMuted,
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
          ] else ...[
            UsageGlassCounter(
              appName: l10n.appTitle,
              todaySeconds: 0,
              compact: false,
            ),
            GGap.m(),
          ],
          GButton(
            label: isTracking ? l10n.stopTracking : l10n.startTracking,
            icon: isTracking ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: onToggle,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

/// Today's app list in one 32px white card; empty state matches “No posts yet…”.
class _TodayUsageCard extends StatelessWidget {
  const _TodayUsageCard({
    required this.apps,
    required this.currentPackage,
  });

  final List<AppUsageEntity> apps;
  final String? currentPackage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (apps.isEmpty) {
      return GCard(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          children: [
            GText(
              l10n.noUsageYet,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            GGap.s(),
            GText(
              l10n.noUsageYetSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
              color: AppTheme.onSurfaceMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GCard(
      header: '${l10n.todaySectionHeader} · ${l10n.appsTracked(apps.length)}',
      child: Column(
        children: [
          for (var i = 0; i < apps.length; i++)
            UsageAppTile(
              entity: apps[i],
              isActive: currentPackage == apps[i].packageName,
              showDivider: i != apps.length - 1,
            ),
        ],
      ),
    );
  }
}
