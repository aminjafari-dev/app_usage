import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/settings/app_timer_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_blur_sheet.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/app_logo.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/duration_wheel_picker.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Opens a sheet to set (or clear) a daily usage limit for [app].
///
/// How to use:
/// ```dart
/// await showAppTimerLimitSheet(context, app: entity);
/// ```
Future<void> showAppTimerLimitSheet(
  BuildContext context, {
  required AppUsageEntity app,
}) {
  return showGBlurredBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<AppTimerCubit>(),
        child: AppTimerLimitSheet(app: app),
      );
    },
  );
}

/// Bottom sheet body: wheel picker + save / clear actions for one app.
class AppTimerLimitSheet extends StatefulWidget {
  /// Creates the per-app daily-limit sheet.
  const AppTimerLimitSheet({super.key, required this.app});

  final AppUsageEntity app;

  @override
  State<AppTimerLimitSheet> createState() => _AppTimerLimitSheetState();
}

class _AppTimerLimitSheetState extends State<AppTimerLimitSheet> {
  late int _hours;
  late int _minutes;
  late bool _hadLimit;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final saved =
        context.read<AppTimerCubit>().limitFor(widget.app.packageName);
    _hadLimit = saved != null;
    if (saved != null) {
      _hours = saved.hours.clamp(0, 23);
      _minutes = DurationWheelPicker.snapMinutes(saved.minutes);
    } else {
      _hours = 1;
      _minutes = 30;
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final totalMinutes = _hours * 60 + _minutes;
    if (totalMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).timerInvalidLimit)),
      );
      return;
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final notify = context
            .read<AppTimerCubit>()
            .limitFor(widget.app.packageName)
            ?.notify ??
        true;

    await context.read<AppTimerCubit>().setLimit(
          AppTimerLimit(
            packageName: widget.app.packageName,
            limitMinutes: totalMinutes,
            notify: notify,
          ),
        );

    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.timerSaved)));
    Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    await context.read<AppTimerCubit>().clearLimit(widget.app.packageName);

    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.timerLimitCleared)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = widget.app;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerOf(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
                GGap.m(),
                AppLogo(iconBytes: app.iconBytes, size: 56),
                GGap.s(),
                GText(
                  app.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                GGap.xs(),
                GText(
                  l10n.timerSetDailyLimit,
                  style: Theme.of(context).textTheme.bodyMedium,
                  color: AppTheme.onSurfaceMuted,
                  textAlign: TextAlign.center,
                ),
                GGap.m(),
                DurationWheelPicker(
                  hours: _hours,
                  minutes: _minutes,
                  hoursLabel: l10n.timerHoursLabel,
                  minutesLabel: l10n.timerMinutesLabel,
                  onHoursChanged: (v) => setState(() => _hours = v),
                  onMinutesChanged: (v) => setState(() => _minutes = v),
                ),
                GGap.m(),
                GButton(
                  label: l10n.timerSetButton,
                  icon: Icons.hourglass_top_rounded,
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
                if (_hadLimit) ...[
                  GGap.s(),
                  TextButton(
                    onPressed: _saving ? null : _clear,
                    child: GText(
                      l10n.timerClearLimit,
                      style: Theme.of(context).textTheme.labelLarge,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
