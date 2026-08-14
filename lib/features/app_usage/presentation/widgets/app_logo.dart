import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';

/// Rounded-square launcher icon from PackageManager bytes (or a soft fallback).
///
/// How to use:
/// ```dart
/// AppLogo(iconBytes: app.iconBytes, size: 44);
/// ```
///
/// Shared by Home and Timer lists so app marks match the timer editor treatment.
class AppLogo extends StatelessWidget {
  /// Creates a rounded app logo at [size].
  const AppLogo({
    super.key,
    this.iconBytes,
    required this.size,
  });

  /// PNG/JPEG bytes from the system package manager; null shows the fallback.
  final List<int>? iconBytes;

  /// Outer width and height of the logo.
  final double size;

  @override
  Widget build(BuildContext context) {
    final bytes = iconBytes;
    final radius = size * 0.28;

    final Widget child;
    if (bytes != null && bytes.isNotEmpty) {
      child = Image.memory(
        Uint8List.fromList(bytes),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(size),
      );
    } else {
      child = _fallback(size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _fallback(double size) {
    return ColoredBox(
      color: AppTheme.primarySoft,
      child: Icon(
        Icons.apps_rounded,
        size: size * 0.5,
        color: AppTheme.primary,
      ),
    );
  }
}
