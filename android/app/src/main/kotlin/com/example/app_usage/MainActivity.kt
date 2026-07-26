package com.example.app_usage

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Host activity that exposes battery-optimization + keepalive MethodChannels.
///
/// How to use from Dart ([BatteryOptimizationDataSource]):
/// ```dart
/// await channel.invokeMethod('isIgnoringBatteryOptimizations');
/// await channel.invokeMethod('requestIgnoreBatteryOptimizations');
/// ```
class MainActivity : FlutterActivity() {
    companion object {
        private const val BATTERY_CHANNEL = "com.example.app_usage/battery"
        private const val KEEPALIVE_CHANNEL = "com.example.app_usage/keepalive"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Battery unrestricted status + system dialog / settings.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BATTERY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                "requestIgnoreBatteryOptimizations" -> {
                    requestIgnoreBatteryOptimizations()
                    result.success(null)
                }
                "openBatterySettings" -> {
                    openBatterySettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Start/stop AlarmManager recovery after Recents "Clear all".
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            KEEPALIVE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    TrackingWatchdog.start(this)
                    result.success(null)
                }
                "stop" -> {
                    TrackingWatchdog.stop(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * When Recents clears this task, schedule a 1s overlay restart before the
     * process is fully torn down.
     *
     * Useful together with Unrestricted battery so AlarmManager is allowed to
     * fire quickly on OEM devices.
     */
    override fun onDestroy() {
        if (TrackingWatchdog.isEnabled(this)) {
            TrackingWatchdog.scheduleQuickRestart(this)
        }
        super.onDestroy()
    }

    /// True when this app is already on the battery "Unrestricted" / ignore list.
    private fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    /// Shows the system "Allow background activity / unrestricted" dialog.
    ///
    /// Useful so clearing Recents does not immediately kill the overlay service.
    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        if (isIgnoringBatteryOptimizations()) return
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    /// Fallback: opens the full battery-optimization list when the dialog fails.
    private fun openBatterySettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        try {
            startActivity(
                Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )
        } catch (_: Exception) {
            // Last resort: app details where OEMs bury "Battery" controls.
            startActivity(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )
        }
    }
}
