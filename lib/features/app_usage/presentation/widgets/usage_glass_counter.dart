import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Glassy / Telegram-blue pill that shows app name + today's formatted duration.
///
/// How to use:
/// ```dart
/// UsageGlassCounter(appName: 'Instagram', todaySeconds: 120);
/// ```
///
/// Shared by the floating overlay and the home-page preview.
/// Keep [compact] true inside the overlay window so text stays within the
/// floating surface; use compact false for the larger home preview.
class UsageGlassCounter extends StatelessWidget {
  /// Creates the glass counter UI.
  const UsageGlassCounter({
    super.key,
    required this.appName,
    required this.todaySeconds,
    this.iconBytes,
    this.compact = true,
  });

  final String appName;
  final int todaySeconds;
  final List<int>? iconBytes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 44.0;
    final nameStyle = TextStyle(
      fontSize: compact ? 13 : 15,
      fontWeight: FontWeight.w500,
      color: AppTheme.overlayText,
      height: 1.1,
    );
    final timeStyle = TextStyle(
      fontSize: compact ? 22 : 26,
      fontWeight: FontWeight.w700,
      color: AppTheme.overlayAccent,
      height: 1.1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Overlay window gives tight bounds; home preview does not.
        final fillParent = constraints.hasBoundedHeight &&
            constraints.maxHeight.isFinite &&
            constraints.maxHeight < 200;

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: fillParent ? double.infinity : (compact ? 260.0 : double.infinity),
              height: fillParent ? double.infinity : (compact ? 88.0 : 96.0),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: compact ? 10 : 14,
              ),
              decoration: BoxDecoration(
                color: AppTheme.glassFill,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(color: AppTheme.glassBorder, width: 1.2),
                boxShadow: compact ? null : AppTheme.cardShadow,
              ),
              // Scale the whole row down when the overlay window is smaller
              // than the design size (density quirks / resize races). Without
              // FittedBox, a tight maxHeight makes the text Column overflow.
              //
              // How to use: keep children at their natural sizes; FittedBox
              // shrinks them uniformly only when the parent is too small.
              // Example: a 40px-tall overlay still shows icon + name + time.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  // Intrinsic design width so Expanded has a real budget when
                  // the outer Container is unbounded (home preview path).
                  width: compact ? 232 : 280,
                  height: 68,
                  child: Row(
                    children: [
                      _IconBubble(iconBytes: iconBytes, size: iconSize),
                      GGap.s(),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appName,
                              style: nameStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatUsageDuration(todaySeconds),
                              style: timeStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Circular app-icon (or fallback glyph) — Telegram chat-avatar style.
class _IconBubble extends StatelessWidget {
  const _IconBubble({this.iconBytes, this.size = 28});

  final List<int>? iconBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    final glyphSize = size * 0.55;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.divider,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? Icon(Icons.apps_rounded, size: glyphSize, color: AppTheme.primary)
          : Image.memory(
              Uint8List.fromList(bytes),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.apps_rounded,
                size: glyphSize,
                color: AppTheme.primary,
              ),
            ),
    );
  }
}

/// List tile for one app — styled like a Telegram chat row.
///
/// How to use inside a ListView / card with [AppUsageEntity] items.
class UsageAppTile extends StatelessWidget {
  /// Creates a row showing icon, name, and today's time.
  const UsageAppTile({
    super.key,
    required this.entity,
    this.isActive = false,
    this.showDivider = true,
  });

  final AppUsageEntity entity;
  final bool isActive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Soft highlight when this app is the live foreground target —
        // similar to Telegram’s selected username / active chat feel.
        ColoredBox(
          color: isActive ? AppTheme.primarySoft : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _IconBubble(iconBytes: entity.iconBytes, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GText(
                        entity.appName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      GText(
                        entity.packageName,
                        style: Theme.of(context).textTheme.bodySmall,
                        color: AppTheme.onSurfaceMuted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Duration sits where Telegram puts timestamps / unread pills.
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.onSurfaceMuted.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: GText(
                    formatUsageDuration(entity.todaySeconds),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    color: isActive ? AppTheme.surface : AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 76),
            child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
          ),
      ],
    );
  }
}
