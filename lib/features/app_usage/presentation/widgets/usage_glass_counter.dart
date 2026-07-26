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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.glassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBubble(iconBytes: iconBytes),
              GGap.s(),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GText(
                      appName,
                      style: Theme.of(context).textTheme.bodySmall,
                      color: AppTheme.overlayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    GText(
                      formatUsageDuration(todaySeconds),
                      style: Theme.of(context).textTheme.titleMedium,
                      color: AppTheme.overlayAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny circular app-icon (or fallback glyph) inside the glass pill.
class _IconBubble extends StatelessWidget {
  const _IconBubble({this.iconBytes});

  final List<int>? iconBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null
          ? const Icon(Icons.apps, size: 16, color: AppTheme.primary)
          : Image.memory(
              Uint8List.fromList(bytes),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.apps, size: 16, color: AppTheme.primary),
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
          _IconBubble(iconBytes: entity.iconBytes),
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
