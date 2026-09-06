import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/settings/app_timer_cubit.dart';
import 'package:app_usage/core/settings/blocked_apps_cubit.dart';
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

/// Timer tab — pick an app and set a daily usage limit or hard block.
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

class _TimerView extends StatelessWidget {
  const _TimerView();

  void _openEditor(BuildContext context, AppUsageEntity app) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TimerEditorPage(app: app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GScaffold(
      title: l10n.navTimer,
      centerTitle: true,
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
            TodayUsageOpCompleted(:final apps) => _AppPickerList(
                apps: apps,
                onSelect: (app) => _openEditor(context, app),
              ),
          };
        },
      ),
    );
  }
}

/// Full-screen editor for one app's daily limit / block settings.
///
/// Pushed above the main shell so the bottom nav is not visible.
class TimerEditorPage extends StatefulWidget {
  /// Creates the per-app timer editor.
  const TimerEditorPage({super.key, required this.app});

  /// App being configured.
  final AppUsageEntity app;

  @override
  State<TimerEditorPage> createState() => _TimerEditorPageState();
}

class _TimerEditorPageState extends State<TimerEditorPage> {
  late int _hours;
  late int _minutes;
  late bool _notify;
  late bool _blocked;
  late bool _blockLocked;

  @override
  void initState() {
    super.initState();
    final packageName = widget.app.packageName;
    final saved = context.read<AppTimerCubit>().limitFor(packageName);
    _blockLocked = BlockedAppsCubit.isLockedDefault(packageName);
    _blocked =
        _blockLocked || context.read<BlockedAppsCubit>().isBlocked(packageName);
    if (saved != null) {
      _hours = saved.hours.clamp(0, 23);
      _minutes = DurationWheelPicker.snapMinutes(saved.minutes);
      _notify = saved.notify;
    } else {
      _hours = 1;
      _minutes = 30;
      _notify = true;
    }
  }

  Future<void> _saveTimer() async {
    final totalMinutes = _hours * 60 + _minutes;
    if (totalMinutes <= 0 && !_blocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).timerInvalidLimit)),
      );
      return;
    }

    final timerCubit = context.read<AppTimerCubit>();
    final blockedCubit = context.read<BlockedAppsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final packageName = widget.app.packageName;
    // Locked defaults stay blocked; only persist the switch for other apps.
    final blocked = _blockLocked ? true : _blocked;

    if (totalMinutes > 0) {
      await timerCubit.setLimit(
        AppTimerLimit(
          packageName: packageName,
          limitMinutes: totalMinutes,
          notify: _notify,
        ),
      );
    }

    if (!_blockLocked) {
      await blockedCubit.setBlocked(packageName, blocked);
    }

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(blocked ? l10n.timerBlockSaved : l10n.timerSaved),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = widget.app;

    return GScaffold(
      title: l10n.navTimer,
      centerTitle: true,
      circularBackButton: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
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
            hours: _hours,
            minutes: _minutes,
            hoursLabel: l10n.timerHoursLabel,
            minutesLabel: l10n.timerMinutesLabel,
            onHoursChanged: (v) => setState(() => _hours = v),
            onMinutesChanged: (v) => setState(() => _minutes = v),
          ),
          GGap.m(),
          GCard(
            child: Column(
              children: [
                GSettingsTile(
                  icon: Icons.notifications_rounded,
                  iconColor: AppTheme.iconTeal,
                  title: l10n.timerNotifyWhenReached,
                  trailing: Switch.adaptive(
                    value: _notify,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (v) => setState(() => _notify = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 72),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppTheme.dividerOf(context),
                  ),
                ),
                GSettingsTile(
                  icon: Icons.block_rounded,
                  iconColor: AppTheme.iconRed,
                  title: l10n.timerBlockWhenOpened,
                  subtitle: _blockLocked
                      ? l10n.timerBlockLockedHint
                      : l10n.timerBlockWhenOpenedHint,
                  trailing: Switch.adaptive(
                    value: _blocked,
                    activeTrackColor: AppTheme.error,
                    onChanged: _blockLocked
                        ? null
                        : (v) => setState(() => _blocked = v),
                  ),
                ),
              ],
            ),
          ),
          GGap.l(),
          GButton(
            label: l10n.timerSetButton,
            icon: Icons.timer_rounded,
            onPressed: _saveTimer,
          ),
        ],
      ),
    );
  }
}

/// Choose which app gets a daily limit / block.
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
    final blocked = context.watch<BlockedAppsCubit>().state;

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
                  blocked: BlockedAppsCubit.isLockedDefault(apps[i].packageName) ||
                      blocked.contains(apps[i].packageName),
                  alwaysBlocked:
                      BlockedAppsCubit.isLockedDefault(apps[i].packageName),
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
    required this.blocked,
    required this.onTap,
    this.alwaysBlocked = false,
    this.showDivider = false,
  });

  final AppUsageEntity app;
  final AppTimerLimit? limit;
  final bool blocked;
  final bool alwaysBlocked;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String subtitle;
    if (alwaysBlocked && limit != null) {
      subtitle = l10n.timerLimitAndBlockedSummary(limit!.hours, limit!.minutes);
    } else if (alwaysBlocked) {
      subtitle = l10n.timerAlwaysBlockedLabel;
    } else if (limit != null && blocked) {
      subtitle = l10n.timerLimitAndBlockedSummary(limit!.hours, limit!.minutes);
    } else if (blocked) {
      subtitle = l10n.timerBlockedLabel;
    } else if (limit != null) {
      subtitle = l10n.timerLimitSummary(limit!.hours, limit!.minutes);
    } else {
      subtitle = formatUsageDuration(app.todaySeconds);
    }

    final accent = limit != null || blocked;

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
                          color: accent
                              ? (blocked ? AppTheme.error : AppTheme.primary)
                              : AppTheme.onSurfaceMuted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (blocked) ...[
                    const Icon(
                      Icons.block_rounded,
                      size: 18,
                      color: AppTheme.error,
                    ),
                    const SizedBox(width: 6),
                  ],
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
