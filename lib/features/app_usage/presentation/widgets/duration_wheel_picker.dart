import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';

/// Custom hours + minutes drum picker (no third-party packages).
///
/// How to use:
/// ```dart
/// DurationWheelPicker(
///   hours: 1,
///   minutes: 30,
///   hoursLabel: 'HOURS',
///   minutesLabel: 'MINUTES',
///   onHoursChanged: (h) {},
///   onMinutesChanged: (m) {},
/// )
/// ```
///
/// Minutes step in increments of [minuteStep] (default 5) to match the
/// compact drum layout.
class DurationWheelPicker extends StatefulWidget {
  /// Creates a dual-column duration wheel.
  const DurationWheelPicker({
    super.key,
    required this.hours,
    required this.minutes,
    required this.hoursLabel,
    required this.minutesLabel,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    this.minuteStep = 5,
    this.maxHours = 23,
  });

  /// Selected hour (`0` … [maxHours]).
  final int hours;

  /// Selected minute (`0` … `59`, snapped to [minuteStep]).
  final int minutes;

  final String hoursLabel;
  final String minutesLabel;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;

  /// Minute increment between drum items (e.g. `5` → 00, 05, 10…).
  final int minuteStep;

  /// Highest hour shown on the left drum.
  final int maxHours;

  /// Snaps [minutes] to the nearest [minuteStep] within `0`–`59`.
  static int snapMinutes(int minutes, {int minuteStep = 5}) {
    final step = minuteStep <= 0 ? 1 : minuteStep;
    final max = (59 ~/ step) * step;
    final snapped = ((minutes / step).round() * step).clamp(0, max);
    return snapped;
  }

  @override
  State<DurationWheelPicker> createState() => _DurationWheelPickerState();
}

class _DurationWheelPickerState extends State<DurationWheelPicker> {
  static const double _itemExtent = 44;
  static const double _pickerHeight = 168;

  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late List<int> _minuteValues;

  int get _hourCount => widget.maxHours + 1;

  @override
  void initState() {
    super.initState();
    _minuteValues = _buildMinuteValues(widget.minuteStep);
    _hoursController = FixedExtentScrollController(
      initialItem: widget.hours.clamp(0, widget.maxHours),
    );
    _minutesController = FixedExtentScrollController(
      initialItem: _minuteIndexFor(widget.minutes),
    );
  }

  @override
  void didUpdateWidget(covariant DurationWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.minuteStep != widget.minuteStep) {
      _minuteValues = _buildMinuteValues(widget.minuteStep);
    }

    final hour = widget.hours.clamp(0, widget.maxHours);
    if (_hoursController.hasClients &&
        _hoursController.selectedItem != hour) {
      _hoursController.jumpToItem(hour);
    }

    final minuteIndex = _minuteIndexFor(widget.minutes);
    if (_minutesController.hasClients &&
        _minutesController.selectedItem != minuteIndex) {
      _minutesController.jumpToItem(minuteIndex);
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  List<int> _buildMinuteValues(int step) {
    final safeStep = step <= 0 ? 1 : step;
    return [for (var m = 0; m < 60; m += safeStep) m];
  }

  int _minuteIndexFor(int minutes) {
    final snapped = DurationWheelPicker.snapMinutes(
      minutes,
      minuteStep: widget.minuteStep,
    );
    final index = _minuteValues.indexOf(snapped);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surfaceOf(context);
    final pill = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.rowStripeDark
        : AppTheme.primarySoft.withValues(alpha: 0.65);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _pickerHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Soft selection capsule behind the drums.
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: _itemExtent,
                      decoration: BoxDecoration(
                        color: pill,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _WheelColumn(
                        controller: _hoursController,
                        itemCount: _hourCount,
                        selectedIndex:
                            widget.hours.clamp(0, widget.maxHours),
                        itemExtent: _itemExtent,
                        labelBuilder: (i) => i.toString().padLeft(2, '0'),
                        onSelectedItemChanged: widget.onHoursChanged,
                      ),
                    ),
                    Expanded(
                      child: _WheelColumn(
                        controller: _minutesController,
                        itemCount: _minuteValues.length,
                        selectedIndex: _minuteIndexFor(widget.minutes),
                        itemExtent: _itemExtent,
                        labelBuilder: (i) =>
                            _minuteValues[i].toString().padLeft(2, '0'),
                        onSelectedItemChanged: (index) {
                          widget.onMinutesChanged(_minuteValues[index]);
                        },
                      ),
                    ),
                  ],
                ),
                // Colon sits above the wheels, between the two columns.
                IgnorePointer(
                  child: GText(
                    ':',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                    color: AppTheme.onSurfaceOf(context),
                  ),
                ),
              ],
            ),
          ),
          GGap.s(),
          Row(
            children: [
              Expanded(
                child: GText(
                  widget.hoursLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                  color: AppTheme.onSurfaceMuted,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: GText(
                  widget.minutesLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                  color: AppTheme.onSurfaceMuted,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One vertical drum; selected row is bold, neighbors fade.
class _WheelColumn extends StatelessWidget {
  const _WheelColumn({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.itemExtent,
    required this.labelBuilder,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final double itemExtent;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    final ink = AppTheme.onSurfaceOf(context);

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: itemExtent,
      perspective: 0.003,
      diameterRatio: 1.35,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final distance = (index - selectedIndex).abs();
          final isSelected = distance == 0;
          final opacity = switch (distance) {
            0 => 1.0,
            1 => 0.38,
            2 => 0.22,
            _ => 0.12,
          };

          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              style: (Theme.of(context).textTheme.headlineMedium ??
                      const TextStyle(fontSize: 20))
                  .copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: ink.withValues(alpha: opacity),
                height: 1,
              ),
              child: Text(labelBuilder(index)),
            ),
          );
        },
      ),
    );
  }
}
