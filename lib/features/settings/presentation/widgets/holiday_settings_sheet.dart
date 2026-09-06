import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/settings/holiday_settings_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_blur_sheet.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Opens the holiday-day bottom sheet and returns when dismissed.
///
/// How to use:
/// ```dart
/// await showHolidaySettingsSheet(context);
/// ```
Future<void> showHolidaySettingsSheet(BuildContext context) {
  return showGBlurredBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<HolidaySettingsCubit>(),
        child: const HolidaySettingsSheet(),
      );
    },
  );
}

/// Localized weekday label for Dart [DateTime.weekday] values (1–7).
String weekdayLabel(AppLocalizations l10n, int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return l10n.weekdayMonday;
    case DateTime.tuesday:
      return l10n.weekdayTuesday;
    case DateTime.wednesday:
      return l10n.weekdayWednesday;
    case DateTime.thursday:
      return l10n.weekdayThursday;
    case DateTime.friday:
      return l10n.weekdayFriday;
    case DateTime.saturday:
      return l10n.weekdaySaturday;
    case DateTime.sunday:
      return l10n.weekdaySunday;
    default:
      return l10n.weekdayFriday;
  }
}

/// Bottom sheet to pick the weekly holiday when blocked apps unlock.
class HolidaySettingsSheet extends StatefulWidget {
  /// Creates the holiday settings sheet body.
  const HolidaySettingsSheet({super.key});

  @override
  State<HolidaySettingsSheet> createState() => _HolidaySettingsSheetState();
}

class _HolidaySettingsSheetState extends State<HolidaySettingsSheet> {
  late HolidaySettings _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = context.read<HolidaySettingsCubit>().state;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<HolidaySettingsCubit>().save(_draft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerOf(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                GGap.m(),
                GText(
                  l10n.holidaySettingsTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                GGap.xs(),
                GText(
                  l10n.holidaySettingsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  color: AppTheme.onSurfaceMuted,
                  textAlign: TextAlign.center,
                ),
                GGap.l(),
                GCard(
                  child: Column(
                    children: [
                      for (var i = 0;
                          i < HolidaySettings.weekdayOptions.length;
                          i++) ...[
                        if (i > 0)
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(start: 72),
                            child: Divider(
                              height: 1,
                              thickness: 0.5,
                              color: AppTheme.dividerOf(context),
                            ),
                          ),
                        _DayTile(
                          label: weekdayLabel(
                            l10n,
                            HolidaySettings.weekdayOptions[i],
                          ),
                          selected: _draft.weekday ==
                              HolidaySettings.weekdayOptions[i],
                          onTap: () {
                            setState(() {
                              _draft = _draft.copyWith(
                                weekday: HolidaySettings.weekdayOptions[i],
                              );
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                GGap.l(),
                GButton(
                  label: l10n.saveChanges,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              GColoredIcon(
                icon: Icons.event_available_rounded,
                color: selected ? AppTheme.iconOrange : AppTheme.iconLightBlue,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GText(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.onSurfaceOf(context),
                      ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: AppTheme.onSurfaceMuted.withValues(alpha: 0.45),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
