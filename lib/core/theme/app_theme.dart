import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color and theme tokens — soft romantic UI for Shirin
/// (32px cards, dusty-rose accents, locale-aware type).
///
/// How to use:
/// ```dart
/// final color = AppTheme.primary;
/// ThemeData theme = AppTheme.lightForLocale(locale);
/// ```
///
/// Always pull colors from here instead of hardcoding `Color(...)` in widgets.
class AppTheme {
  AppTheme._();

  /// Dusty rose — primary CTAs, active tabs, links, section headers.
  static const Color primary = Color(0xFFE891A0);

  /// Slightly deeper rose for pressed / emphasis states.
  static const Color primaryDark = Color(0xFFD47082);

  /// Soft blush used behind active nav icons and selected chips.
  static const Color primarySoft = Color(0xFFFCE8EC);

  /// Soft rose tint for primary button drop shadows.
  static const Color primaryShadow = Color(0x66E891A0);

  /// Page canvas — light cool grey behind white cards.
  static const Color background = Color(0xFFF1F3F6);

  /// Dark-mode page canvas.
  static const Color backgroundDark = Color(0xFF0F141A);

  /// Card / surface fill — pure white.
  static const Color surface = Color(0xFFFFFFFF);

  /// Dark-mode card / surface fill.
  static const Color surfaceDark = Color(0xFF1A222D);

  /// Floating notch nav — cool mist white, a step off pure card white.
  static const Color navBar = Color(0xFFF6F8FB);

  /// Dark-mode floating notch nav — a step above card surface.
  static const Color navBarDark = Color(0xFF243040);

  /// Primary text — dark navy / charcoal.
  static const Color onSurface = Color(0xFF1A202C);

  /// Dark-mode primary text.
  static const Color onSurfaceDark = Color(0xFFF1F3F6);

  /// Secondary / caption text — medium cool grey.
  static const Color onSurfaceMuted = Color(0xFF8A94A6);

  /// Thin list dividers inside cards.
  static const Color divider = Color(0xFFE8ECF0);

  /// Dark-mode list dividers.
  static const Color dividerDark = Color(0xFF2A3340);

  /// Alternating row stripe inside info cards.
  static const Color rowStripe = Color(0xFFF5F7FA);

  /// Dark-mode row stripe / segmented track.
  static const Color rowStripeDark = Color(0xFF242C38);

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
  static const Color overlayAccent = Color(0xFFE891A0);

  /// Minimal overlay timer chip — off-white pill + soft rose clock glyph.
  static const Color overlayChipFill = Color(0xFFF4F4F4);
  static const Color overlayChipIcon = Color(0xFFE8A0AB);
  static const Color overlayChipText = Color(0xFF2D2D2D);

  /// Soft amber for the over-limit alert on the overlay chip.
  static const Color overlayChipAlert = Color(0xFFE0A14A);

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

  /// Soft rose glow under primary CTAs.
  static List<BoxShadow> get primaryButtonShadow => [
        BoxShadow(
          color: primaryShadow,
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  /// Canvas color for the active brightness.
  static Color canvasOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : background;
  }

  /// Card / surface color for the active brightness.
  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surface;
  }

  /// Floating bottom-nav fill for the active brightness.
  static Color navBarOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? navBarDark
        : navBar;
  }

  /// Primary text color for the active brightness.
  static Color onSurfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? onSurfaceDark
        : onSurface;
  }

  /// Divider color for the active brightness.
  static Color dividerOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dividerDark
        : divider;
  }

  /// Soft track / stripe color for the active brightness.
  static Color stripeOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? rowStripeDark
        : rowStripe;
  }

  /// Light theme with Inter (English).
  static ThemeData light() => lightForLocale(const Locale('en'));

  /// Dark theme with Inter (English).
  static ThemeData dark() => darkForLocale(const Locale('en'));

  /// Light theme — Baloo Bhaijaan 2 for Persian, Inter otherwise.
  static ThemeData lightForLocale(Locale locale) => _build(
        brightness: Brightness.light,
        canvas: background,
        card: surface,
        ink: onSurface,
        line: divider,
        stripe: rowStripe,
        usePersianFont: locale.languageCode == 'fa',
      );

  /// Dark theme — Baloo Bhaijaan 2 for Persian, Inter otherwise.
  static ThemeData darkForLocale(Locale locale) => _build(
        brightness: Brightness.dark,
        canvas: backgroundDark,
        card: surfaceDark,
        ink: onSurfaceDark,
        line: dividerDark,
        stripe: rowStripeDark,
        usePersianFont: locale.languageCode == 'fa',
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color canvas,
    required Color card,
    required Color ink,
    required Color line,
    required Color stripe,
    required bool usePersianFont,
  }) {
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: iconTeal,
      surface: card,
      error: error,
      brightness: brightness,
    );

    final baseTextTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: ink,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ink,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.25,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.25,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.35,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceMuted,
        height: 1.3,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.dark ? ink : surface,
        height: 1.2,
      ),
      labelMedium: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.2,
      ),
    );

    // Cute round Persian type for FA; Inter for English.
    final textTheme = usePersianFont
        ? GoogleFonts.balooBhaijaan2TextTheme(baseTextTheme)
        : GoogleFonts.interTextTheme(baseTextTheme);

    final fontFamily = usePersianFont
        ? GoogleFonts.balooBhaijaan2().fontFamily
        : GoogleFonts.inter().fontFamily;

    TextStyle titledStyle({
      required double fontSize,
      required FontWeight fontWeight,
      required Color color,
    }) {
      return usePersianFont
          ? GoogleFonts.balooBhaijaan2(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            )
          : GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: base,
      fontFamily: fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: line,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: titledStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        iconTheme: IconThemeData(color: ink, size: 22),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 4,
        shape: CircleBorder(),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: stripe,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: 3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusCard),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: titledStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: brightness == Brightness.dark ? backgroundDark : surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
    );
  }
}
