import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';

/// App-wide text widget that reads styles from [AppTheme] / [ThemeData].
///
/// How to use:
/// ```dart
/// GText('Hello', style: Theme.of(context).textTheme.titleMedium);
/// ```
///
/// Prefer this over raw [Text] so typography stays consistent and themed.
class GText extends StatelessWidget {
  /// Creates a themed text widget.
  ///
  /// Example:
  /// ```dart
  /// const GText('Title');
  /// ```
  const GText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = (style ?? Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(color: color);

    return Text(
      data,
      style: resolvedStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Convenience text that always uses the muted on-surface color.
///
/// Useful for secondary descriptions under a title.
class GTextMuted extends StatelessWidget {
  /// Creates muted body text.
  const GTextMuted(
    this.data, {
    super.key,
    this.textAlign,
    this.maxLines,
  });

  final String data;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return GText(
      data,
      style: Theme.of(context).textTheme.bodySmall,
      color: AppTheme.onSurfaceMuted,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
