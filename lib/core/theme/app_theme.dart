import 'package:flutter/material.dart';

/// Central color and theme tokens extracted from Telegram’s light UI.
///
/// How to use:
/// ```dart
/// final color = AppTheme.primary;
/// ThemeData theme = AppTheme.light();
/// ```
///
/// Always pull colors from here instead of hardcoding `Color(...)` in widgets.
/// Useful when keeping the whole app visually consistent with the Telegram
/// palette (blue accents, light grey canvas, white rounded cards).
class AppTheme {
  AppTheme._();

  /// Telegram blue — primary CTAs, active tabs, links, section headers.
  static const Color primary = Color(0xFF24A1DE);

  /// Slightly deeper blue for pressed / emphasis states.
  static const Color primaryDark = Color(0xFF1E88C5);

  /// Soft blue used behind active nav icons and selected chips.
  static const Color primarySoft = Color(0xFFE3F2FD);

  /// Page canvas — light neutral grey behind white cards.
  static const Color background = Color(0xFFF0F2F5);

  /// Card / surface fill — pure white.
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text — near black.
  static const Color onSurface = Color(0xFF000000);

  /// Secondary / caption text — Telegram grey.
  static const Color onSurfaceMuted = Color(0xFF8E8E93);

  /// Thin list dividers inside cards.
  static const Color divider = Color(0xFFE8E8E8);

  /// Error / destructive accent (Telegram red).
  static const Color error = Color(0xFFFF3B30);

  /// Success / granted accent (Telegram green).
  static const Color success = Color(0xFF4CD964);

  /// Colored icon tile backgrounds (settings-style rounded squares).
  static const Color iconBlue = Color(0xFF2481CC);
  static const Color iconOrange = Color(0xFFF09A37);
  static const Color iconGreen = Color(0xFF4CD964);
  static const Color iconRed = Color(0xFFFF3B30);
  static const Color iconTeal = Color(0xFF5AC8FA);
  static const Color iconPurple = Color(0xFFB669F0);

  /// Floating overlay glass fill / border (still translucent over apps).
  static const Color glassFill = Color(0xE6FFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color overlayText = Color(0xFF000000);
  static const Color overlayAccent = Color(0xFF24A1DE);

  /// Shared radii matching Telegram’s soft card / pill look.
  static const double radiusCard = 16;
  static const double radiusPill = 24;
  static const double radiusIcon = 10;
  static const double radiusAvatar = 48;

  /// Subtle card shadow used on white Telegram cards.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: onSurface.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

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
      secondary: iconTeal,
      surface: surface,
      error: error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 3,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface,
        contentTextStyle: const TextStyle(color: surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: onSurfaceMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: surface,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }
}
