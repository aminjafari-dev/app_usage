import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/settings/app_timer_cubit.dart';
import 'package:app_usage/core/settings/blocked_apps_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/analytics_period.dart';
import 'package:app_usage/features/app_usage/domain/entities/daily_usage_chart_point.dart';
import 'package:app_usage/features/app_usage/domain/entities/period_usage_snapshot.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/analytics_cubit.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';
import 'package:app_usage/features/settings/presentation/widgets/settings_choice_segment.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Analytics tab: period totals, chart, and ranked apps.
///
/// How to use: hosted inside [MainShellPage] via [IndexedStack].
class AnalyticsPage extends StatelessWidget {
  /// Creates the Analytics tab; cubit is provided internally via get_it.
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<AnalyticsCubit>()..load(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.analyticsTitle,
      centerTitle: true,
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => context.read<AnalyticsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                SettingsChoiceSegment(
                  choices: [
                    SettingsChoice(label: l10n.analyticsPeriodThreeDays),
                    SettingsChoice(label: l10n.analyticsPeriodWeek),
                    SettingsChoice(label: l10n.analyticsPeriodTenDays),
                  ],
                  selectedIndex: state.period.index,
                  onChanged: (index) {
                    context
                        .read<AnalyticsCubit>()
                        .selectPeriod(AnalyticsPeriod.values[index]);
                  },
                ),
                GGap.l(),
                ...switch (state.status) {
                  AnalyticsStatus.initial || AnalyticsStatus.loading => [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  AnalyticsStatus.error => [
                      GCard(
                        padding: const EdgeInsets.all(20),
                        child: GText(
                          state.errorMessage ?? l10n.errorGeneric,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  AnalyticsStatus.loaded => [
                      if (state.snapshot != null)
                        _LoadedBody(snapshot: state.snapshot!),
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

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.snapshot});

  final PeriodUsageSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chartPoints = chartPointsFor(snapshot);
    final limits = context.watch<AppTimerCubit>().state;
    final blocked = context.watch<BlockedAppsCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GText(
          formatUsageDuration(snapshot.totalSeconds),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ),
        GGap.xs(),
        GText(
          l10n.analyticsTotalLabel,
          style: Theme.of(context).textTheme.bodySmall,
          color: AppTheme.onSurfaceMuted,
          textAlign: TextAlign.center,
        ),
        GGap.s(),
        GText(
          l10n.analyticsAveragePerDay(
            formatUsageDuration(snapshot.averageSecondsPerDay),
          ),
          style: Theme.of(context).textTheme.bodySmall,
          color: AppTheme.onSurfaceMuted,
          textAlign: TextAlign.center,
        ),
        GGap.l(),
        GCard(
          header: l10n.analyticsChartHeader,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: SizedBox(
            height: 160,
            child: _UsageBarChart(points: chartPoints),
          ),
        ),
        GGap.l(),
        if (snapshot.apps.isEmpty)
          GCard(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                GText(
                  l10n.analyticsNoData,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                GGap.s(),
                GText(
                  l10n.analyticsNoDataSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  color: AppTheme.onSurfaceMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          GCard(
            header: l10n.analyticsAppsHeader,
            child: Column(
              children: [
                for (final app in snapshot.apps)
                  UsageAppTile(
                    entity: app,
                    showDivider: false,
                    limit: limits[app.packageName],
                    blocked: blocked.contains(app.packageName),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Builds one chart bar per local day in the snapshot.
List<UsageChartPoint> chartPointsFor(PeriodUsageSnapshot snapshot) {
  return [
    for (final b in snapshot.dailyBuckets)
      UsageChartPoint(
        labelDay: b.day,
        totalSeconds: b.totalSeconds,
      ),
  ];
}

/// Simple vertical bar chart for daily / weekly usage totals.
class _UsageBarChart extends StatelessWidget {
  const _UsageBarChart({required this.points});

  final List<UsageChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return Center(
        child: GText(
          l10n.analyticsNoData,
          color: AppTheme.onSurfaceMuted,
        ),
      );
    }

    final maxSeconds = points
        .map((p) => p.totalSeconds)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final peak = maxSeconds <= 0 ? 1 : maxSeconds;
    final locale = Localizations.localeOf(context).toString();
    final labelFormat = points.length > 14
        ? DateFormat.Md(locale)
        : DateFormat.E(locale);
    // Skip labels when many bars so the axis stays readable.
    final labelStep = points.length <= 7
        ? 1
        : points.length <= 14
            ? 2
            : (points.length / 6).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final barMaxHeight = constraints.maxHeight - 28;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < points.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: barMaxHeight,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          height: ((points[i].totalSeconds / peak) * barMaxHeight)
                              .clamp(2.0, barMaxHeight),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(
                              alpha: points[i].totalSeconds > 0 ? 0.9 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 14,
                      child: GText(
                        i % labelStep == 0 || i == points.length - 1
                            ? labelFormat.format(points[i].labelDay)
                            : '',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                            ),
                        color: AppTheme.onSurfaceMuted,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
