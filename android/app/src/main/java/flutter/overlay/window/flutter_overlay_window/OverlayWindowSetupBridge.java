package flutter.overlay.window.flutter_overlay_window;

import android.view.Gravity;
import android.view.WindowManager;

/**
 * Restores the overlay window geometry that {@code showOverlay} normally sets.
 *
 * <p>How to use, from native code that restarts {@link OverlayService} without
 * going through Dart (see {@code TrackingWatchdog}):
 *
 * <pre>
 * OverlayWindowSetupBridge.applyBadgeWindow(widthPx, heightPx, title, content);
 * context.startForegroundService(new Intent(context, OverlayService.class));
 * </pre>
 *
 * <p>Why this class lives in the plugin's package: {@link WindowSetup} holds the
 * geometry in package-private statics that only the Dart {@code showOverlay}
 * call writes. Once the app process dies those statics fall back to
 * {@code MATCH_PARENT x MATCH_PARENT} with {@code Gravity.CENTER}, so a native
 * restart would add a full-screen touchable window. That window paints nothing
 * but still swallows every tap on the device, which looks exactly like a broken
 * touchscreen.
 *
 * <p>Sizes are raw pixels here because the plugin feeds {@link WindowSetup#width}
 * and {@link WindowSetup#height} straight into {@code WindowManager.LayoutParams}
 * (unlike {@code resizeOverlay}, which converts dp).
 */
public final class OverlayWindowSetupBridge {

    private OverlayWindowSetupBridge() {
    }

    /**
     * Applies the small draggable badge window used by the live usage counter.
     *
     * <p>Mirrors the arguments {@code OverlayDataSource.show} passes to
     * {@code showOverlay}. Non-positive sizes are rejected so a bad cache can
     * never fall back to the full-screen default.
     *
     * @return true when the geometry was applied.
     */
    public static boolean applyBadgeWindow(
            int widthPx,
            int heightPx,
            String title,
            String content
    ) {
        if (widthPx <= 0 || heightPx <= 0) {
            return false;
        }
        WindowSetup.width = widthPx;
        WindowSetup.height = heightPx;
        WindowSetup.gravity = Gravity.TOP;
        WindowSetup.flag = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        WindowSetup.enableDrag = true;
        WindowSetup.positionGravity = "none";
        if (title != null) {
            WindowSetup.overlayTitle = title;
        }
        if (content != null) {
            WindowSetup.overlayContent = content;
        }
        return true;
    }

    /**
     * Whether the plugin still holds its full-screen defaults.
     *
     * <p>Useful as a last-resort check before adding a window: true means no
     * {@code showOverlay} ran in this process yet.
     */
    public static boolean isFullScreenDefault() {
        return WindowSetup.width == WindowManager.LayoutParams.MATCH_PARENT
                && WindowSetup.height == WindowManager.LayoutParams.MATCH_PARENT;
    }
}
