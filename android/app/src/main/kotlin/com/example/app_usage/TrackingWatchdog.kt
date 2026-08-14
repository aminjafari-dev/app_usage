package com.example.app_usage

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.SystemClock
import flutter.overlay.window.flutter_overlay_window.OverlayService
import flutter.overlay.window.flutter_overlay_window.OverlayWindowSetupBridge
import kotlin.math.roundToInt

/**
 * Schedules AlarmManager restarts so the overlay can recover after Recents clear.
 *
 * How to use from [MainActivity] keepalive channel:
 * - `start` → mark enabled + schedule the next check
 * - `stop` → mark disabled + cancel alarms
 * - `cacheOverlayWindow` → remember the badge window Dart last asked for
 *
 * Why: when the user clears all apps, OEM battery savers often kill the process
 * even with a foreground overlay. Exact alarms (plus Unrestricted battery) bring
 * the floating counter back within about a second.
 */
object TrackingWatchdog {
    private const val PREFS = "app_usage_keepalive_prefs"
    private const val KEY_ENABLED = "keepalive_enabled"
    private const val KEY_WINDOW_WIDTH = "overlay_window_width_px"
    private const val KEY_WINDOW_HEIGHT = "overlay_window_height_px"
    private const val KEY_WINDOW_TITLE = "overlay_window_title"
    private const val KEY_WINDOW_CONTENT = "overlay_window_content"
    private const val REQUEST_CODE = 42043
    private const val QUICK_RESTART_MS = 1_000L
    private const val WATCHDOG_INTERVAL_MS = 60_000L

    /** Badge chip size in dp, mirroring `OverlayDataSource.logicalSizeFor`. */
    private const val FALLBACK_WIDTH_DP = 100
    private const val FALLBACK_HEIGHT_DP = 28

    /** Start offset in dp, mirroring `OverlayDataSource.show`. */
    private const val START_X_DP = 0
    private const val START_Y_DP = 40

    /** Notification copy used only before Dart ever cached its own. */
    private const val DEFAULT_WINDOW_TITLE = "App Usage"
    private const val DEFAULT_WINDOW_CONTENT = "Live usage counter is running"

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

    /**
     * Remembers the exact window Dart passed to `showOverlay`.
     *
     * How to use from the keepalive channel whenever the overlay is shown:
     * `cacheOverlayWindow(context, 420, 108, 'App Usage', '…')`.
     *
     * Required because [restartOverlay] runs in a fresh process where the
     * plugin's static geometry is back to full screen.
     */
    fun cacheOverlayWindow(
        context: Context,
        widthPx: Int,
        heightPx: Int,
        title: String,
        content: String,
    ) {
        if (widthPx <= 0 || heightPx <= 0) return
        prefs(context).edit()
            .putInt(KEY_WINDOW_WIDTH, widthPx)
            .putInt(KEY_WINDOW_HEIGHT, heightPx)
            .putString(KEY_WINDOW_TITLE, title)
            .putString(KEY_WINDOW_CONTENT, content)
            .apply()
    }

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
        // The plugin keeps window geometry in statics that only Dart's
        // showOverlay writes, and this restart runs in a fresh process where
        // they are back to MATCH_PARENT. Restoring them first is what keeps the
        // recreated window a small badge instead of a transparent full-screen
        // layer that eats every touch on the device.
        if (!applyCachedWindow(context)) return

        // Always pass a non-null Intent — plugin START_STICKY null restarts NPE.
        val overlayIntent = Intent(context, OverlayService::class.java).apply {
            putExtra("startX", START_X_DP)
            putExtra("startY", START_Y_DP)
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

    /**
     * Restores the badge geometry saved by [cacheOverlayWindow].
     *
     * Returns false when the overlay window would still be created at the
     * plugin's full-screen default, in which case the caller must not start the
     * service: an invisible full-screen window blocks touches everywhere.
     */
    private fun applyCachedWindow(context: Context): Boolean {
        val prefs = prefs(context)
        val density = context.resources.displayMetrics.density
        val width = prefs.getInt(KEY_WINDOW_WIDTH, 0).takeIf { it > 0 }
            ?: (FALLBACK_WIDTH_DP * density).roundToInt()
        val height = prefs.getInt(KEY_WINDOW_HEIGHT, 0).takeIf { it > 0 }
            ?: (FALLBACK_HEIGHT_DP * density).roundToInt()

        val applied = OverlayWindowSetupBridge.applyBadgeWindow(
            width,
            height,
            prefs.getString(KEY_WINDOW_TITLE, null) ?: DEFAULT_WINDOW_TITLE,
            prefs.getString(KEY_WINDOW_CONTENT, null) ?: DEFAULT_WINDOW_CONTENT,
        )
        return applied && !OverlayWindowSetupBridge.isFullScreenDefault()
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
