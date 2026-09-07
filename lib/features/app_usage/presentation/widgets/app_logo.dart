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
///
/// Caches a [MemoryImage] so parent [setState] rebuilds (timer wheel / switches)
/// do not re-decode the icon and flash.
class AppLogo extends StatefulWidget {
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
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  MemoryImage? _image;

  @override
  void initState() {
    super.initState();
    _syncImage();
  }

  @override
  void didUpdateWidget(covariant AppLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.iconBytes, widget.iconBytes)) {
      _syncImage();
    }
  }

  void _syncImage() {
    final bytes = widget.iconBytes;
    if (bytes == null || bytes.isEmpty) {
      _image = null;
      return;
    }
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    _image = MemoryImage(data);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.size * 0.28;
    final image = _image;

    final Widget child;
    if (image != null) {
      child = Image(
        image: image,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(widget.size),
      );
    } else {
      child = _fallback(widget.size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: child,
      ),
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
