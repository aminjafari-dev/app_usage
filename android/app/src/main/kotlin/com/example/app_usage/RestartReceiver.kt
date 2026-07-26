package com.example.app_usage

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * AlarmManager / boot callback that recovers the overlay counter.
 *
 * How to use: scheduled by [TrackingWatchdog] after Recents clear, on a 60s
 * heartbeat, and on BOOT_COMPLETED from the manifest.
 */
class RestartReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action
        // Boot / package-replace should only act when tracking was left on.
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == Intent.ACTION_LOCKED_BOOT_COMPLETED
        ) {
            if (!TrackingWatchdog.isEnabled(context)) return
            TrackingWatchdog.onAlarm(context)
            return
        }

        // Default: AlarmManager tick from [TrackingWatchdog.schedule].
        TrackingWatchdog.onAlarm(context)
    }
}
