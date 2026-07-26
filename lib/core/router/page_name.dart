/// Named route constants used by [PageRouter].
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushNamed(PageName.home);
/// ```
///
/// Never hardcode route strings like "/home" in widgets.
class PageName {
  PageName._();

  /// Home dashboard with today's usage list and start/stop controls.
  static const String home = '/home';

  /// Permission onboarding for usage access + overlay.
  static const String permissions = '/permissions';

  /// Shown on non-Android platforms.
  static const String unsupported = '/unsupported';
}
