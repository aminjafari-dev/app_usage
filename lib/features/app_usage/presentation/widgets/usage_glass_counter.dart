import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Glassy pill that shows app name + today's formatted duration.
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
    final iconSize = compact ? 36.0 : 40.0;
    final nameStyle = TextStyle(
      fontSize: compact ? 13 : 14,
      fontWeight: FontWeight.w500,
      color: AppTheme.overlayText,
      height: 1.1,
    );
    final timeStyle = TextStyle(
      fontSize: compact ? 22 : 24,
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
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: fillParent ? double.infinity : (compact ? 260.0 : 280.0),
              height: fillParent ? double.infinity : (compact ? 88.0 : 96.0),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: compact ? 10 : 14,
              ),
              decoration: BoxDecoration(
                color: AppTheme.glassFill,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.glassBorder, width: 1.2),
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
                  width: compact ? 232 : 244,
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

/// Circular app-icon (or fallback glyph) inside the glass pill.
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
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? Icon(Icons.apps, size: glyphSize, color: AppTheme.primary)
          : Image.memory(
              Uint8List.fromList(bytes),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.apps, size: glyphSize, color: AppTheme.primary),
            ),
    );
  }
}

/// List tile for one app on the home dashboard.
///
/// How to use inside a ListView.builder with [AppUsageEntity] items.
class UsageAppTile extends StatelessWidget {
  /// Creates a row showing icon, name, and today's time.
  const UsageAppTile({super.key, required this.entity, this.isActive = false});

  final AppUsageEntity entity;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primary.withValues(alpha: 0.08)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.35)
              : AppTheme.onSurfaceMuted.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          _IconBubble(iconBytes: entity.iconBytes, size: 32),
          GGap.s(),
          Expanded(
            child: GText(
              entity.appName,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GText(
            formatUsageDuration(entity.todaySeconds),
            style: Theme.of(context).textTheme.titleMedium,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
