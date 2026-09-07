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
import 'package:app_usage/features/app_usage/presentation/bloc/timer_cubit.dart';
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
      create: (_) => locator<TimerCubit>()..load(),
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
      body: BlocBuilder<TimerCubit, TimerState>(
        builder: (context, state) {
          return switch (state.status) {
            TimerStatus.initial || TimerStatus.loading => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            TimerStatus.error => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GText(
                        state.errorMessage ?? l10n.errorGeneric,
                        color: AppTheme.error,
                        textAlign: TextAlign.center,
                      ),
                      GGap.m(),
                      GButton(
                        label: l10n.refresh,
                        icon: Icons.refresh_rounded,
                        onPressed: () => context.read<TimerCubit>().load(),
                      ),
                    ],
                  ),
                ),
              ),
            TimerStatus.loaded => _AppPickerList(
                mostUsedApps: state.mostUsedApps,
                otherApps: state.otherApps,
                searchQuery: state.searchQuery,
                onSearchChanged: context.read<TimerCubit>().search,
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

  @override
  void initState() {
    super.initState();
    final saved =
        context.read<AppTimerCubit>().limitFor(widget.app.packageName);
    _blocked =
        context.read<BlockedAppsCubit>().isBlocked(widget.app.packageName);
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
    final blocked = _blocked;
    final packageName = widget.app.packageName;

    if (totalMinutes > 0) {
      await timerCubit.setLimit(
        AppTimerLimit(
          packageName: packageName,
          limitMinutes: totalMinutes,
          notify: _notify,
        ),
      );
    }

    await blockedCubit.setBlocked(packageName, blocked);

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
                  subtitle: l10n.timerBlockWhenOpenedHint,
                  trailing: Switch.adaptive(
                    value: _blocked,
                    activeTrackColor: AppTheme.error,
                    onChanged: (v) => setState(() => _blocked = v),
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
    required this.mostUsedApps,
    required this.otherApps,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSelect,
  });

  final List<AppUsageEntity> mostUsedApps;
  final List<AppUsageEntity> otherApps;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<AppUsageEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limits = context.watch<AppTimerCubit>().state;
    final blocked = context.watch<BlockedAppsCubit>().state;
    final hasQuery = searchQuery.trim().isNotEmpty;
    final isEmpty = mostUsedApps.isEmpty && otherApps.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GText(
                l10n.timerPickAppHint,
                style: Theme.of(context).textTheme.bodyMedium,
                color: AppTheme.onSurfaceMuted,
              ),
              GGap.m(),
              _AppSearchField(
                hintText: l10n.timerSearchHint,
                onChanged: onSearchChanged,
              ),
            ],
          ),
        ),
        GGap.m(),
        Expanded(
          child: isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 120),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasQuery
                              ? Icons.search_off_rounded
                              : Icons.apps_outlined,
                          size: 48,
                          color: AppTheme.onSurfaceMuted,
                        ),
                        GGap.m(),
                        GText(
                          hasQuery
                              ? l10n.timerSearchEmptyTitle
                              : l10n.timerEmptyTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        GGap.s(),
                        GText(
                          hasQuery
                              ? l10n.timerSearchEmptySubtitle
                              : l10n.timerEmptySubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                          color: AppTheme.onSurfaceMuted,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  children: [
                    if (mostUsedApps.isNotEmpty) ...[
                      _AppSectionCard(
                        header: l10n.todaySectionHeader,
                        apps: mostUsedApps,
                        limits: limits,
                        blocked: blocked,
                        onSelect: onSelect,
                      ),
                      if (otherApps.isNotEmpty) GGap.m(),
                    ],
                    if (otherApps.isNotEmpty)
                      _AppSectionCard(
                        header: mostUsedApps.isEmpty
                            ? null
                            : l10n.timerOtherAppsHeader,
                        apps: otherApps,
                        limits: limits,
                        blocked: blocked,
                        onSelect: onSelect,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// One titled card of apps for the Timer picker.
class _AppSectionCard extends StatelessWidget {
  const _AppSectionCard({
    required this.apps,
    required this.limits,
    required this.blocked,
    required this.onSelect,
    this.header,
  });

  final String? header;
  final List<AppUsageEntity> apps;
  final Map<String, AppTimerLimit> limits;
  final Set<String> blocked;
  final ValueChanged<AppUsageEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    return GCard(
      header: header,
      child: Column(
        children: [
          for (var i = 0; i < apps.length; i++)
            _AppLimitTile(
              app: apps[i],
              limit: limits[apps[i].packageName],
              blocked: blocked.contains(apps[i].packageName),
              showDivider: i < apps.length - 1,
              onTap: () => onSelect(apps[i]),
            ),
        ],
      ),
    );
  }
}

/// Soft search field matching the card / settings visual language.
class _AppSearchField extends StatefulWidget {
  const _AppSearchField({
    required this.hintText,
    required this.onChanged,
  });

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<_AppSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge,
      cursorColor: AppTheme.primary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceMuted,
            ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.onSurfaceMuted,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
              },
              icon: const Icon(
                Icons.close_rounded,
                color: AppTheme.onSurfaceMuted,
              ),
            );
          },
        ),
        filled: true,
        fillColor: AppTheme.surfaceOf(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard / 2),
          borderSide: BorderSide(color: AppTheme.dividerOf(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard / 2),
          borderSide: BorderSide(color: AppTheme.dividerOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard / 2),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _AppLimitTile extends StatelessWidget {
  const _AppLimitTile({
    required this.app,
    required this.limit,
    required this.blocked,
    required this.onTap,
    this.showDivider = false,
  });

  final AppUsageEntity app;
  final AppTimerLimit? limit;
  final bool blocked;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String subtitle;
    if (limit != null && blocked) {
      subtitle = l10n.timerLimitAndBlockedSummary(limit!.hours, limit!.minutes);
    } else if (blocked) {
      subtitle = l10n.timerBlockedLabel;
    } else if (limit != null) {
      subtitle = l10n.timerLimitSummary(limit!.hours, limit!.minutes);
    } else if (app.todaySeconds > 0) {
      subtitle = formatUsageDuration(app.todaySeconds);
    } else {
      subtitle = l10n.timerNoLimitSet;
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
