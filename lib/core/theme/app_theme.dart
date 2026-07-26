import 'package:flutter/material.dart';

/// Central color and theme tokens for the whole app.
///
/// How to use:
/// ```dart
/// final color = AppTheme.glassFill;
/// ThemeData theme = AppTheme.light();
/// ```
///
/// Always pull colors from here instead of hardcoding Color(...) in widgets.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1F6F8B);
  static const Color secondary = Color(0xFF21A0A0);
  static const Color background = Color(0xFFF3F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF14212B);
  static const Color onSurfaceMuted = Color(0xFF5C6B76);
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF1B7F4E);
  static const Color glassFill = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color overlayText = Color(0xFF0F1A22);
  static const Color overlayAccent = Color(0xFF1F6F8B);

  /// Builds the light Material theme used by [MaterialApp].
  ///
  /// Example:
  /// ```dart
  /// MaterialApp(theme: AppTheme.light());
  /// ```
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: surface,
        ),
      ),
    );
  }
}
