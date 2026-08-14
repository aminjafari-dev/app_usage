import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_usage/core/settings/coach_settings_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_blur_sheet.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/settings/presentation/widgets/settings_choice_segment.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Opens the coach-reminders bottom sheet and returns when dismissed.
///
/// How to use:
/// ```dart
/// await showCoachSettingsSheet(context);
/// ```
Future<void> showCoachSettingsSheet(BuildContext context) {
  return showGBlurredBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<CoachSettingsCubit>(),
        child: const CoachSettingsSheet(),
      );
    },
  );
}

/// Bottom sheet to tune snooze interval, daily cap, and mute option.
class CoachSettingsSheet extends StatefulWidget {
  /// Creates the coach settings sheet body.
  const CoachSettingsSheet({super.key});

  @override
  State<CoachSettingsSheet> createState() => _CoachSettingsSheetState();
}

class _CoachSettingsSheetState extends State<CoachSettingsSheet> {
  late CoachSettings _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = context.read<CoachSettingsCubit>().state;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await context.read<CoachSettingsCubit>().save(_draft);
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
    final snoozeIndex = CoachSettings.snoozeOptions
        .indexOf(_draft.snoozeMinutes)
        .clamp(0, CoachSettings.snoozeOptions.length - 1);
    final maxIndex =
        CoachSettings.maxNudgeOptions.indexOf(_draft.maxNudgesPerDay).clamp(0, 3);

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
                  l10n.coachSettingsTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                GGap.xs(),
                GText(
                  l10n.coachSettingsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  color: AppTheme.onSurfaceMuted,
                  textAlign: TextAlign.center,
                ),
                GGap.l(),
                GCard(
                  child: GSettingsTile(
                    icon: Icons.notifications_active_rounded,
                    iconColor: AppTheme.iconTeal,
                    title: l10n.coachSettingsEnabled,
                    subtitle: l10n.coachSettingsEnabledHint,
                    trailing: Switch.adaptive(
                      value: _draft.enabled,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (v) {
                        setState(() => _draft = _draft.copyWith(enabled: v));
                      },
                    ),
                  ),
                ),
                GGap.m(),
                GText(
                  l10n.coachSettingsSnoozeLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GGap.xs(),
                GText(
                  l10n.coachSettingsSnoozeHint,
                  style: Theme.of(context).textTheme.bodySmall,
                  color: AppTheme.onSurfaceMuted,
                ),
                GGap.s(),
                SettingsChoiceSegment(
                  choices: [
                    for (final m in CoachSettings.snoozeOptions)
                      SettingsChoice(label: l10n.coachSettingsMinutes(m)),
                  ],
                  selectedIndex: snoozeIndex,
                  onChanged: (i) {
                    setState(() {
                      _draft = _draft.copyWith(
                        snoozeMinutes: CoachSettings.snoozeOptions[i],
                      );
                    });
                  },
                ),
                GGap.l(),
                GText(
                  l10n.coachSettingsMaxNudgesLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GGap.xs(),
                GText(
                  l10n.coachSettingsMaxNudgesHint,
                  style: Theme.of(context).textTheme.bodySmall,
                  color: AppTheme.onSurfaceMuted,
                ),
                GGap.s(),
                SettingsChoiceSegment(
                  choices: [
                    for (final n in CoachSettings.maxNudgeOptions)
                      SettingsChoice(label: '$n'),
                  ],
                  selectedIndex: maxIndex,
                  onChanged: (i) {
                    setState(() {
                      _draft = _draft.copyWith(
                        maxNudgesPerDay: CoachSettings.maxNudgeOptions[i],
                      );
                    });
                  },
                ),
                GGap.m(),
                GCard(
                  child: GSettingsTile(
                    icon: Icons.volume_off_rounded,
                    iconColor: AppTheme.iconOrange,
                    title: l10n.coachSettingsAllowMute,
                    subtitle: l10n.coachSettingsAllowMuteHint,
                    trailing: Switch.adaptive(
                      value: _draft.allowMuteToday,
                      activeTrackColor: AppTheme.primary,
                      onChanged: _draft.enabled
                          ? (v) {
                              setState(
                                () => _draft = _draft.copyWith(allowMuteToday: v),
                              );
                            }
                          : null,
                    ),
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
