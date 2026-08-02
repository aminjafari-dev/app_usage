import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/utils/duration_format.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/app_usage/domain/entities/app_usage_entity.dart';

/// Minimal timer chip — foreground app logo + bold mm:ss (or h:mm:ss).
///
/// How to use:
/// ```dart
/// UsageGlassCounter(
///   appName: 'Instagram',
///   todaySeconds: 120,
///   iconBytes: preview.iconBytes,
/// );
/// ```
///
/// Shared by the floating overlay and the home-page preview.
/// Pass [iconBytes] from PackageManager so the chip shows the open app's logo.
class UsageGlassCounter extends StatelessWidget {
  /// Creates the minimal timer chip.
  ///
  /// [sizeScale] and [opacity] come from badge appearance settings
  /// (`1.0` / `0.9` are the defaults).
  const UsageGlassCounter({
    super.key,
    required this.appName,
    required this.todaySeconds,
    this.iconBytes,
    this.compact = true,
    this.sizeScale = 1.0,
    this.opacity = 0.9,
  });

  final String appName;
  final int todaySeconds;
  final List<int>? iconBytes;
  final bool compact;
  final double sizeScale;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final scale = sizeScale.clamp(0.5, 1.5);
    final iconSize = (compact ? 18.0 : 22.0) * scale;
    final fontSize = (compact ? 13.0 : 15.0) * scale;
    final hPad = (compact ? 8.0 : 10.0) * scale;
    final vPad = (compact ? 5.0 : 7.0) * scale;
    final gap = (compact ? 6.0 : 8.0) * scale;

    return Align(
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity.clamp(0.3, 1.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: AppTheme.overlayChipFill,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ChipAppLogo(iconBytes: iconBytes, size: iconSize),
              SizedBox(width: gap),
              Text(
                formatUsageDuration(todaySeconds),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.overlayChipText,
                  height: 1.0,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny circular launcher icon for the timer chip (fallback: sage clock).
class _ChipAppLogo extends StatelessWidget {
  const _ChipAppLogo({this.iconBytes, required this.size});

  final List<int>? iconBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    if (bytes == null || bytes.isEmpty) {
      return Icon(
        Icons.timelapse_rounded,
        size: size,
        color: AppTheme.overlayChipIcon,
      );
    }

    return ClipOval(
      child: Image.memory(
        Uint8List.fromList(bytes),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.timelapse_rounded,
          size: size,
          color: AppTheme.overlayChipIcon,
        ),
      ),
    );
  }
}

/// Circular app-icon (or fallback glyph).
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

/// List tile for one app — avatar + name + duration pill.
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
        ColoredBox(
          color: isActive ? AppTheme.primarySoft : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _IconBubble(iconBytes: entity.iconBytes, size: 44),
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
            padding: EdgeInsetsDirectional.only(start: 72),
            child: Divider(height: 1, thickness: 0.5, color: AppTheme.divider),
          ),
      ],
    );
  }
}
