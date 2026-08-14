import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/settings/app_timer_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_bloc.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_event.dart';
import 'package:app_usage/features/app_usage/presentation/bloc/usage_state.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/app_logo.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/duration_wheel_picker.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Timer tab — pick an app and set a daily usage limit.
///
/// How to use: hosted inside [MainShellPage] via [IndexedStack].
class TimerPage extends StatelessWidget {
  /// Creates the timer tab.
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<UsageBloc>()..add(const UsageEvent.started()),
      child: const _TimerView(),
    );
  }
}

class _TimerView extends StatefulWidget {
  const _TimerView();

  @override
  State<_TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<_TimerView> {
  AppUsageEntity? _selected;
  int _hours = 1;
  int _minutes = 30;
  bool _notify = true;

  void _selectApp(AppUsageEntity app) {
    final saved = context.read<AppTimerCubit>().limitFor(app.packageName);
    setState(() {
      _selected = app;
      if (saved != null) {
        _hours = saved.hours.clamp(0, 23);
        _minutes = DurationWheelPicker.snapMinutes(saved.minutes);
        _notify = saved.notify;
      } else {
        _hours = 1;
        _minutes = 30;
        _notify = true;
      }
    });
  }

  void _clearSelection() {
    setState(() => _selected = null);
  }

  Future<void> _saveTimer() async {
    final app = _selected;
    if (app == null) return;

    final totalMinutes = _hours * 60 + _minutes;
    if (totalMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).timerInvalidLimit)),
      );
      return;
    }

    await context.read<AppTimerCubit>().setLimit(
          AppTimerLimit(
            packageName: app.packageName,
            limitMinutes: totalMinutes,
            notify: _notify,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).timerSaved)),
    );
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;

    return GScaffold(
      title: l10n.navTimer,
      centerTitle: true,
      leading: selected == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Center(
                child: Material(
                  color: AppTheme.surfaceOf(context),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _clearSelection,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.dividerOf(context)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppTheme.onSurfaceOf(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: BlocBuilder<UsageBloc, UsageState>(
        builder: (context, state) {
          return switch (state.todayUsage) {
            TodayUsageOpInitial() || TodayUsageOpLoading() => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            TodayUsageOpError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: GText(message, color: AppTheme.error),
                ),
              ),
            TodayUsageOpCompleted(:final apps) => selected == null
                ? _AppPickerList(
                    apps: apps,
                    onSelect: _selectApp,
                  )
                : _TimerEditor(
                    app: selected,
                    hours: _hours,
                    minutes: _minutes,
                    notify: _notify,
                    onHoursChanged: (v) => setState(() => _hours = v),
                    onMinutesChanged: (v) => setState(() => _minutes = v),
                    onNotifyChanged: (v) => setState(() => _notify = v),
                    onSave: _saveTimer,
                  ),
          };
        },
      ),
    );
  }
}

/// Choose which app gets a daily limit.
class _AppPickerList extends StatelessWidget {
  const _AppPickerList({
    required this.apps,
    required this.onSelect,
  });

  final List<AppUsageEntity> apps;
  final ValueChanged<AppUsageEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limits = context.watch<AppTimerCubit>().state;

    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 48,
                color: AppTheme.onSurfaceMuted,
              ),
              GGap.m(),
              GText(
                l10n.timerEmptyTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              GGap.s(),
              GText(
                l10n.timerEmptySubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                color: AppTheme.onSurfaceMuted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        GText(
          l10n.timerPickAppHint,
          style: Theme.of(context).textTheme.bodyMedium,
          color: AppTheme.onSurfaceMuted,
        ),
        GGap.m(),
        GCard(
          child: Column(
            children: [
              for (var i = 0; i < apps.length; i++)
                _AppLimitTile(
                  app: apps[i],
                  limit: limits[apps[i].packageName],
                  showDivider: i < apps.length - 1,
                  onTap: () => onSelect(apps[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppLimitTile extends StatelessWidget {
  const _AppLimitTile({
    required this.app,
    required this.limit,
    required this.onTap,
    this.showDivider = false,
  });

  final AppUsageEntity app;
  final AppTimerLimit? limit;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = limit == null
        ? formatUsageDuration(app.todaySeconds)
        : l10n.timerLimitSummary(limit!.hours, limit!.minutes);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AppLogo(iconBytes: app.iconBytes, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GText(
                          app.appName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        GText(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                          color: limit != null
                              ? AppTheme.primary
                              : AppTheme.onSurfaceMuted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 72),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: AppTheme.dividerOf(context),
            ),
          ),
      ],
    );
  }
}

/// Hours / minutes wheel + notify toggle + save CTA for one app.
class _TimerEditor extends StatelessWidget {
  const _TimerEditor({
    required this.app,
    required this.hours,
    required this.minutes,
    required this.notify,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onNotifyChanged,
    required this.onSave,
  });

  final AppUsageEntity app;
  final int hours;
  final int minutes;
  final bool notify;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<bool> onNotifyChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        Column(
          children: [
            GGap.s(),
            AppLogo(iconBytes: app.iconBytes, size: 72),
            GGap.m(),
            GText(
              app.appName,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            GGap.xs(),
            GText(
              l10n.timerSetDailyLimit,
              style: Theme.of(context).textTheme.bodyMedium,
              color: AppTheme.onSurfaceMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        GGap.l(),
        DurationWheelPicker(
          hours: hours,
          minutes: minutes,
          hoursLabel: l10n.timerHoursLabel,
          minutesLabel: l10n.timerMinutesLabel,
          onHoursChanged: onHoursChanged,
          onMinutesChanged: onMinutesChanged,
        ),
        GGap.m(),
        GCard(
          child: GSettingsTile(
            icon: Icons.notifications_rounded,
            iconColor: AppTheme.iconTeal,
            title: l10n.timerNotifyWhenReached,
            trailing: Switch.adaptive(
              value: notify,
              activeTrackColor: AppTheme.primary,
              onChanged: onNotifyChanged,
            ),
          ),
        ),
        GGap.l(),
        GButton(
          label: l10n.timerSetButton,
          icon: Icons.timer_rounded,
          onPressed: onSave,
        ),
      ],
    );
  }
}
