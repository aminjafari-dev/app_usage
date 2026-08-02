import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_text.dart';

/// One option in a settings segmented control.
class SettingsChoice {
  /// Creates a labeled option with an optional leading icon.
  const SettingsChoice({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

/// Capsule segmented control for language / theme rows.
///
/// How to use:
/// ```dart
/// SettingsChoiceSegment(
///   choices: [
///     SettingsChoice(label: 'English'),
///     SettingsChoice(label: 'فارسی'),
///   ],
///   selectedIndex: 0,
///   onChanged: (i) {},
/// );
/// ```
class SettingsChoiceSegment extends StatelessWidget {
  /// Creates a pill track with a raised selected capsule.
  const SettingsChoiceSegment({
    super.key,
    required this.choices,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<SettingsChoice> choices;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedFill = isDark ? AppTheme.surfaceDark : AppTheme.surface;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.stripeOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < choices.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color:
                        i == selectedIndex ? selectedFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    boxShadow: i == selectedIndex
                        ? [
                            BoxShadow(
                              color: AppTheme.onSurface.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (choices[i].icon != null) ...[
                        Icon(
                          choices[i].icon,
                          size: 16,
                          color: i == selectedIndex
                              ? AppTheme.primary
                              : AppTheme.onSurfaceMuted,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: GText(
                          choices[i].label,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: i == selectedIndex
                                        ? AppTheme.primary
                                        : AppTheme.onSurfaceMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
