package com.example.app_usage

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.SystemClock
import flutter.overlay.window.flutter_overlay_window.OverlayService

/**
 * Schedules AlarmManager restarts so the overlay can recover after Recents clear.
 *
 * How to use from [MainActivity] keepalive channel:
 * - `start` → mark enabled + schedule the next check
 * - `stop` → mark disabled + cancel alarms
 *
 * Why: when the user clears all apps, OEM battery savers often kill the process
 * even with a foreground overlay. Exact alarms (plus Unrestricted battery) bring
 * the floating counter back within about a second.
 */
object TrackingWatchdog {
    private const val PREFS = "app_usage_keepalive_prefs"
    private const val KEY_ENABLED = "keepalive_enabled"
    private const val REQUEST_CODE = 42043
    private const val QUICK_RESTART_MS = 1_000L
    private const val WATCHDOG_INTERVAL_MS = 60_000L

    /// Call when live tracking starts so Recents-clear can recover the badge.
    fun start(context: Context) {
        prefs(context).edit().putBoolean(KEY_ENABLED, true).apply()
        schedule(context, QUICK_RESTART_MS)
    }

    /// Call when the user stops live tracking.
    fun stop(context: Context) {
        prefs(context).edit().putBoolean(KEY_ENABLED, false).apply()
        cancel(context)
    }

    /// Whether Dart previously enabled background recovery.
    fun isEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_ENABLED, false)

    /// Schedules a near-immediate restart (e.g. from [MainActivity.onDestroy]).
    fun scheduleQuickRestart(context: Context) {
        if (!isEnabled(context)) return
        schedule(context, QUICK_RESTART_MS)
    }

    /// Runs one recovery pass, then schedules the next periodic check.
    fun onAlarm(context: Context) {
        if (!isEnabled(context)) return

        // OverlayService.isRunning is public in flutter_overlay_window.
        if (!OverlayService.isRunning) {
            restartOverlay(context)
        }

        // Keep a 60s heartbeat so aggressive OEMs cannot leave us dead forever.
        schedule(context, WATCHDOG_INTERVAL_MS)
    }

    private fun restartOverlay(context: Context) {
        // Always pass a non-null Intent — plugin START_STICKY null restarts NPE.
        val overlayIntent = Intent(context, OverlayService::class.java).apply {
            putExtra("startX", -6)
            putExtra("startY", -6)
            putExtra("IsCloseWindow", false)
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(overlayIntent)
            } else {
                context.startService(overlayIntent)
            }
        } catch (_: Exception) {
            // May fail briefly while battery restrictions still apply.
        }
    }

    private fun schedule(context: Context, delayMs: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pending = pendingIntent(context)
        val triggerAt = SystemClock.elapsedRealtime() + delayMs

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAt,
                pending,
            )
        } else {
            alarmManager.setExact(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAt,
                pending,
            )
        }
    }

    private fun cancel(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent(context))
    }

    private fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, RestartReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getBroadcast(context, REQUEST_CODE, intent, flags)
    }

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
