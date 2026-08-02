import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:app_usage/core/settings/badge_appearance_cubit.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_button.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/presentation/widgets/usage_glass_counter.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Opens the customize-badge bottom sheet and returns when dismissed.
///
/// How to use:
/// ```dart
/// await showBadgeAppearanceSheet(context);
/// ```
Future<void> showBadgeAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppTheme.onSurface.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<BadgeAppearanceCubit>(),
        child: const BadgeAppearanceSheet(),
      );
    },
  );
}

/// Bottom sheet with size / opacity sliders for the floating badge.
///
/// How to use: prefer [showBadgeAppearanceSheet] so theming and cubit wiring
/// stay consistent.
class BadgeAppearanceSheet extends StatefulWidget {
  /// Creates the customize-badge sheet body.
  const BadgeAppearanceSheet({super.key});

  @override
  State<BadgeAppearanceSheet> createState() => _BadgeAppearanceSheetState();
}

class _BadgeAppearanceSheetState extends State<BadgeAppearanceSheet> {
  late BadgeAppearance _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = context.read<BadgeAppearanceCubit>().state;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await context.read<BadgeAppearanceCubit>().save(_draft);

      // Notify the overlay isolate only — resizeOverlay must run there
      // (main-isolate calls hit a missing MethodChannel and can tear the
      // floating FlutterView down).
      try {
        if (await FlutterOverlayWindow.isActive()) {
          await FlutterOverlayWindow.shareData(_draft.toMap());
        }
      } catch (_) {
        // Overlay may be mid-teardown; prefs are already persisted.
      }

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
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusCard),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: SafeArea(
          top: false,
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
                GText(
                  l10n.customizeBadgeTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                GGap.l(),
                // Live preview so size/opacity changes are obvious before save.
                UsageGlassCounter(
                  appName: l10n.appTitle,
                  todaySeconds: 83,
                  compact: false,
                  sizeScale: _draft.sizeScale,
                  opacity: _draft.opacity,
                ),
                GGap.l(),
                _AppearanceSlider(
                  label: l10n.badgeSizeLabel,
                  valueLabel: '${_draft.sizePercent}%',
                  // Index into [BadgeAppearance.sizeSteps]: 0.75 → 1 → 1.5 → 2.
                  value: BadgeAppearance.sizeStepIndex(_draft.sizeScale)
                      .toDouble(),
                  min: 0,
                  max: (BadgeAppearance.sizeSteps.length - 1).toDouble(),
                  divisions: BadgeAppearance.sizeSteps.length - 1,
                  onChanged: (index) {
                    setState(() {
                      _draft = _draft.copyWith(
                        sizeScale:
                            BadgeAppearance.sizeSteps[index.round()],
                      );
                    });
                  },
                ),
                GGap.l(),
                _AppearanceSlider(
                  label: l10n.badgeOpacityLabel,
                  valueLabel: '${_draft.opacityPercent}%',
                  value: _draft.opacity,
                  min: BadgeAppearance.minOpacity,
                  max: BadgeAppearance.maxOpacity,
                  // 30% → 40% → … → 100%.
                  divisions: ((BadgeAppearance.maxOpacity -
                              BadgeAppearance.minOpacity) /
                          BadgeAppearance.opacityStep)
                      .round(),
                  onChanged: (value) {
                    setState(() {
                      _draft = _draft.copyWith(opacity: value);
                    });
                  },
                ),
                GGap.xl(),
                GButton(
                  label: l10n.saveChanges,
                  icon: Icons.check_rounded,
                  onPressed: _save,
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppearanceSlider extends StatelessWidget {
  const _AppearanceSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GText(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                color: AppTheme.onSurfaceMuted,
              ),
            ),
            GText(
              valueLabel,
              style: Theme.of(context).textTheme.titleMedium,
              color: AppTheme.onSurfaceOf(context),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
