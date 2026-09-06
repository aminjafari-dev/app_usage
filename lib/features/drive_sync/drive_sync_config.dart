/// Remote Drive sync endpoint configuration (free Apps Script web app).
///
/// How to use: after deploying `backend/apps_script/Code.gs`, rebuild with:
/// `--dart-define=DRIVE_SYNC_URL=https://script.google.com/macros/s/.../exec`
/// `--dart-define=DRIVE_SYNC_API_KEY=app_usage_sync_7f3a9c2e1b84d0f6`
class DriveSyncConfig {
  const DriveSyncConfig._();

  /// Apps Script web app URL ending in `/exec` (no trailing slash needed).
  ///
  /// Replace the default after you deploy the script, or pass `--dart-define`.
  static const baseUrl = String.fromEnvironment(
    'DRIVE_SYNC_URL',
    defaultValue:
        'https://script.google.com/macros/s/AKfycbwsgnur2TpIB33qrSvn6HMTRNrue7CFX23Dm6KsZxJO3eG8kzemeB05UkYdvYLxTIXq/exec',
  );

  /// Shared secret checked in the Apps Script `apiKey` body field.
  static const apiKey = String.fromEnvironment(
    'DRIVE_SYNC_API_KEY',
    defaultValue: 'app_usage_sync_7f3a9c2e1b84d0f6',
  );

  /// Preferred local hour (24h) for the daily background sync attempt.
  static const syncHourLocal = 12;

  /// Whether [baseUrl] still needs a real Apps Script deployment id.
  static bool get isConfigured =>
      baseUrl.contains('/macros/s/') &&
      !baseUrl.contains('REPLACE_WITH_YOUR_DEPLOYMENT_ID');
}
