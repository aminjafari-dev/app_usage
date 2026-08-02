import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_text.dart';

/// Soft white card with 32px corners — groups related list/content items.
///
/// How to use:
/// ```dart
/// GCard(
///   header: 'Accounts',
///   child: Column(children: [row1, row2]),
/// );
/// ```
///
/// Section [header] sits above the white surface (blue label), matching the
/// settings “Accounts” pattern. Cards float on the light grey canvas.
class GCard extends StatelessWidget {
  /// Creates a soft surface card.
  ///
  /// When [header] is set, a blue section title is drawn above [child].
  const GCard({
    super.key,
    required this.child,
    this.header,
    this.padding = EdgeInsets.zero,
    this.margin,
  });

  final Widget child;
  final String? header;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue section label lives outside the white card.
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: GText(
                header!,
                style: Theme.of(context).textTheme.labelMedium,
                color: AppTheme.primary,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: AppTheme.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

/// Colored circular icon used on settings / contacts rows.
///
/// How to use:
/// ```dart
/// GColoredIcon(icon: Icons.lock, color: AppTheme.iconGreen);
/// ```
class GColoredIcon extends StatelessWidget {
  /// Creates a solid-color circular icon tile with a white glyph.
  const GColoredIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 32,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppTheme.surface, size: size * 0.52),
    );
  }
}

/// Settings-style list row: circular icon + title + subtitle + trailing.
///
/// How to use:
/// ```dart
/// GSettingsTile(
///   icon: Icons.shield,
///   iconColor: AppTheme.iconGreen,
///   title: 'Privacy',
///   subtitle: 'Last seen, devices',
///   onTap: () {},
/// );
/// ```
class GSettingsTile extends StatelessWidget {
  /// Creates one interactive settings / info row.
  ///
  /// When [showDivider] is true a faint inset line is drawn under the row.
  const GSettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  GColoredIcon(icon: icon, color: iconColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GText(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          GText(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                            color: AppTheme.onSurfaceMuted,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
        // Inset divider — starts after the icon like settings list separators.
        if (showDivider)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 62),
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

/// Compact pill badge (Granted / Required / unread-style counts).
///
/// How to use:
/// ```dart
/// GPillBadge(label: 'Granted', tone: GPillTone.success);
/// ```
enum GPillTone { success, danger, muted, primary }

class GPillBadge extends StatelessWidget {
  /// Creates a small rounded status chip.
  const GPillBadge({
    super.key,
    required this.label,
    this.tone = GPillTone.muted,
  });

  final String label;
  final GPillTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      GPillTone.success => (
          AppTheme.success.withValues(alpha: 0.14),
          AppTheme.success,
        ),
      GPillTone.danger => (
          AppTheme.error.withValues(alpha: 0.14),
          AppTheme.error,
        ),
      GPillTone.primary => (AppTheme.primarySoft, AppTheme.primary),
      GPillTone.muted => (
          AppTheme.onSurfaceMuted.withValues(alpha: 0.12),
          AppTheme.onSurfaceMuted,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: GText(
        label,
        style: Theme.of(context).textTheme.bodySmall,
        color: fg,
      ),
    );
  }
}

/// Horizontal quick-action tile (profile “Set Photo / Edit Info / Settings”).
///
/// How to use:
/// ```dart
/// GQuickAction(
///   icon: Icons.refresh,
///   label: 'Refresh',
///   onTap: () {},
/// );
/// ```
class GQuickAction extends StatelessWidget {
  /// Creates one of the small white action cards in a horizontal row.
  const GQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = AppTheme.onSurfaceOf(context);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: ink, size: 22),
                  const SizedBox(height: 8),
                  GText(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                    color: ink,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Value + muted label stack used inside profile info cards.
///
/// How to use:
/// ```dart
/// GInfoRow(value: '+98 …', label: 'Mobile', striped: true);
/// ```
class GInfoRow extends StatelessWidget {
  /// Creates one value/label pair, optionally striped.
  const GInfoRow({
    super.key,
    required this.value,
    required this.label,
    this.striped = false,
    this.onTap,
  });

  final String value;
  final String label;
  final bool striped;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: striped ? AppTheme.stripeOf(context) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GText(
                value,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              GText(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                color: AppTheme.onSurfaceMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Capsule segmented control (e.g. Posts / Archived Posts).
///
/// How to use:
/// ```dart
/// GSegmentedTabs(
///   tabs: ['Posts', 'Archived'],
///   selectedIndex: 0,
///   onChanged: (i) {},
/// );
/// ```
class GSegmentedTabs extends StatelessWidget {
  /// Creates a pill track with a soft-blue selected capsule.
  const GSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedFill = isDark ? AppTheme.surfaceDark : AppTheme.surface;
    final selectedFg = AppTheme.primary;
    final unselectedFg = AppTheme.onSurfaceMuted;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.stripeOf(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? selectedFill : Colors.transparent,
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
                  child: GText(
                    tabs[i],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: i == selectedIndex ? selectedFg : unselectedFg,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
