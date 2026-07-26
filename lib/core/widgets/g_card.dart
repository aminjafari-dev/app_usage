import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_text.dart';

/// Telegram-style white rounded card that groups related list/content items.
///
/// How to use:
/// ```dart
/// GCard(
///   child: Column(children: [row1, row2]),
/// );
/// ```
///
/// Useful for recreating Telegram’s settings / contacts / account sections —
/// white surface, soft radius, optional section header, floating on grey canvas.
class GCard extends StatelessWidget {
  /// Creates a Telegram-style surface card.
  ///
  /// When [header] is set, a blue section title is drawn above [child]
  /// (e.g. “Accounts”, “Your Info”).
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
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blue Telegram section header — useful for grouping rows like
          // “Your Info” or “Accounts” in settings screens.
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: GText(
                header!,
                style: Theme.of(context).textTheme.labelMedium,
                color: AppTheme.primary,
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Colored rounded-square icon used on Telegram settings / contacts rows.
///
/// How to use:
/// ```dart
/// GColoredIcon(icon: Icons.lock, color: AppTheme.iconGreen);
/// ```
class GColoredIcon extends StatelessWidget {
  /// Creates a solid-color rounded icon tile with a white glyph.
  const GColoredIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 36,
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
        borderRadius: BorderRadius.circular(AppTheme.radiusIcon),
      ),
      child: Icon(icon, color: AppTheme.surface, size: size * 0.55),
    );
  }
}

/// Telegram settings-style list row: colored icon + title + subtitle + trailing.
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
  /// When [showDivider] is true a faint inset line is drawn under the row —
  /// matching Telegram’s card-internal separators.
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        // Subtitle mirrors Telegram’s grey description under titles.
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
        // Inset divider — starts after the icon like Telegram list separators.
        if (showDivider)
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 66),
            child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
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
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppTheme.primary, size: 22),
                  const SizedBox(height: 6),
                  GText(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    color: AppTheme.onSurface,
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
