import 'package:flutter/services.dart';

/// Talks to native battery-optimization + keepalive MethodChannels.
///
/// How to use:
/// ```dart
/// final ds = BatteryOptimizationDataSource();
/// if (!await ds.isUnrestricted()) await ds.requestUnrestricted();
/// await ds.startWatchdog();
/// ```
///
/// Useful because OEM battery savers kill the overlay when the user clears
/// all apps from Recents unless the app is set to Unrestricted.
class BatteryOptimizationDataSource {
  static const _batteryChannel =
      MethodChannel('com.example.app_usage/battery');
  static const _keepaliveChannel =
      MethodChannel('com.example.app_usage/keepalive');

  /// Whether Android already ignores battery optimizations for this app.
  ///
  /// Example: show a green "Granted" chip on the permissions page.
  Future<bool> isUnrestricted() async {
    try {
      final value =
          await _batteryChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return value ?? false;
    } on MissingPluginException {
      // Non-Android / tests — treat as unrestricted so UI is not blocked.
      return true;
    } on PlatformException {
      return false;
    }
  }

  /// Opens the system dialog asking the user to allow Unrestricted battery.
  ///
  /// How to use: wire to the permissions card CTA. After the user returns,
  /// call [isUnrestricted] again via refresh.
  Future<void> requestUnrestricted() async {
    try {
      await _batteryChannel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    } on PlatformException {
      // Fall back to the full battery settings list.
      await openBatterySettings();
    }
  }

  /// Opens the battery-optimization settings list (OEM fallback).
  Future<void> openBatterySettings() async {
    try {
      await _batteryChannel.invokeMethod<void>('openBatterySettings');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    } on PlatformException {
      // Ignore — user can open settings manually.
    }
  }

  /// Starts AlarmManager recovery so Clear-all can bring the overlay back.
  ///
  /// Call together with showing the overlay when live tracking starts.
  Future<void> startWatchdog() async {
    try {
      await _keepaliveChannel.invokeMethod<void>('start');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    } on PlatformException {
      // Ignore — overlay may still run while the process lives.
    }
  }

  /// Stops AlarmManager recovery when the user disables live tracking.
  Future<void> stopWatchdog() async {
    try {
      await _keepaliveChannel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    } on PlatformException {
      // Ignore.
    }
  }
}
