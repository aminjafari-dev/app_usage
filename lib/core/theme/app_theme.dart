import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color and theme tokens — minimal soft-UI language from the
/// shared profile / settings designs (32px cards, sky-blue accents).
///
/// How to use:
/// ```dart
/// final color = AppTheme.primary;
/// ThemeData theme = AppTheme.light();
/// ```
///
/// Always pull colors from here instead of hardcoding `Color(...)` in widgets.
class AppTheme {
  AppTheme._();

  /// Sky blue — primary CTAs, active tabs, links, section headers.
  static const Color primary = Color(0xFF3390EC);

  /// Slightly deeper blue for pressed / emphasis states.
  static const Color primaryDark = Color(0xFF2481CC);

  /// Soft blue used behind active nav icons and selected chips.
  static const Color primarySoft = Color(0xFFDCEEFF);

  /// Soft blue tint for primary button drop shadows.
  static const Color primaryShadow = Color(0x663390EC);

  /// Page canvas — light cool grey behind white cards.
  static const Color background = Color(0xFFF1F3F6);

  /// Card / surface fill — pure white.
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary text — dark navy / charcoal.
  static const Color onSurface = Color(0xFF1A202C);

  /// Secondary / caption text — medium cool grey.
  static const Color onSurfaceMuted = Color(0xFF8A94A6);

  /// Thin list dividers inside cards.
  static const Color divider = Color(0xFFE8ECF0);

  /// Alternating row stripe inside info cards.
  static const Color rowStripe = Color(0xFFF5F7FA);

  /// Error / destructive accent.
  static const Color error = Color(0xFFFF3B30);

  /// Success / granted accent.
  static const Color success = Color(0xFF4CD964);

  /// Colored icon tile backgrounds (settings-style circular glyphs).
  static const Color iconBlue = Color(0xFF2481CC);
  static const Color iconOrange = Color(0xFFF09A37);
  static const Color iconGreen = Color(0xFF4CD964);
  static const Color iconRed = Color(0xFFFF3B30);
  static const Color iconTeal = Color(0xFF5AC8FA);
  static const Color iconPurple = Color(0xFFB669F0);
  static const Color iconLightBlue = Color(0xFF64B5F6);

  /// Floating overlay glass fill / border (still translucent over apps).
  static const Color glassFill = Color(0xE6FFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color overlayText = Color(0xFF1A202C);
  static const Color overlayAccent = Color(0xFF3390EC);

  /// Minimal overlay timer chip — off-white pill + sage clock glyph.
  static const Color overlayChipFill = Color(0xFFF4F4F4);
  static const Color overlayChipIcon = Color(0xFFA8C69F);
  static const Color overlayChipText = Color(0xFF2D2D2D);

  /// Shared radii — 32px cards/buttons; full capsule for pills.
  static const double radiusCard = 32;
  static const double radiusPill = 999;
  static const double radiusIcon = 999;
  static const double radiusAvatar = 48;

  /// Page horizontal inset shared by list screens.
  static const double pagePadding = 16;

  /// Subtle card shadow — soft depth without harsh borders.
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: onSurface.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// Soft blue glow under primary CTAs (e.g. “Add a post”).
  static List<BoxShadow> get primaryButtonShadow => [
        BoxShadow(
          color: primaryShadow,
          blurRadius: 18,
          offset: const Offset(0, 8),
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

    // Inter across the app — matches the Figma typeface.
    final textTheme = GoogleFonts.interTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: onSurface,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: onSurface,
          height: 1.25,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
          height: 1.25,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceMuted,
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: surface,
          height: 1.2,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
          height: 1.2,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        iconTheme: const IconThemeData(color: onSurface, size: 22),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface,
        contentTextStyle: GoogleFonts.inter(color: surface, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
    );
  }
}
