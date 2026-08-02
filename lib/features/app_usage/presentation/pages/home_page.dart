import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/router/page_name.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
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

/// Home dashboard: today's total usage + per-app list.
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

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              context.read<UsageBloc>().add(const UsageEvent.refreshUsage());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                if (!permissionsReady) ...[
                  _PermissionsBanner(
                    onOpen: () {
                      Navigator.of(context).pushNamed(PageName.permissions);
                    },
                  ),
                  GGap.l(),
                ],
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
                      _TotalUsageCard(apps: apps),
                      GGap.l(),
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

/// Sum of today's usage across every tracked app.
class _TotalUsageCard extends StatelessWidget {
  const _TotalUsageCard({required this.apps});

  final List<AppUsageEntity> apps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalSeconds = apps.fold<int>(0, (sum, app) => sum + app.todaySeconds);

    return  Column(
        children: [
          GGap.m(),
          GText(
            formatUsageDuration(totalSeconds),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ),
          GGap.xs(),
          GText(
            l10n.appsTracked(apps.length),
            style: Theme.of(context).textTheme.bodySmall,
            color: AppTheme.onSurfaceMuted,
          ),
        ],
    );
  }
}

/// Today's app list; empty state when nothing has been tracked yet.
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
      header: l10n.todaySectionHeader,
      child: Column(
        children: [
          for (final app in apps)
            UsageAppTile(
              entity: app,
              isActive: currentPackage == app.packageName,
              showDivider: false,
            ),
        ],
      ),
    );
  }
}
