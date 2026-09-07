import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/features/app_usage/presentation/pages/analytics_page.dart';
import 'package:app_usage/features/app_usage/presentation/pages/home_page.dart';
import 'package:app_usage/features/app_usage/presentation/pages/timer_page.dart';
import 'package:app_usage/features/settings/presentation/pages/settings_page.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Root shell after permissions — notch bottom nav switches between tabs.
///
/// How to use:
/// ```dart
/// Navigator.of(context).pushReplacementNamed(PageName.home);
/// ```
///
/// Child pages can switch tabs via [MainShellScope.of].
/// Tabs: Home, Analytics, Timer, Settings.
class MainShellPage extends StatefulWidget {
  /// Creates the main tab shell.
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  static const _exitConfirmWindow = Duration(seconds: 2);

  int _index = 0;
  DateTime? _lastBackPressAt;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (_index == index) return;
    _controller.jumpTo(index);
    setState(() => _index = index);
  }

  /// First back shows a hint; a second back within [_exitConfirmWindow] exits.
  void _handleRootBack() {
    final now = DateTime.now();
    final last = _lastBackPressAt;
    final confirmed =
        last != null && now.difference(last) <= _exitConfirmWindow;

    if (confirmed) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressAt = now;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.pressBackAgainToExit),
        duration: _exitConfirmWindow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bg = AppTheme.canvasOf(context);
    final navBar = AppTheme.navBarOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = AppTheme.onSurfaceMuted;
    final overlayStyle = (isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: bg,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleRootBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: MainShellScope(
          selectedIndex: _index,
          onSelectTab: _selectTab,
          child: Scaffold(
            backgroundColor: bg,
            // Body paints under the floating bar so page content shows around it.
            extendBody: true,
            body: Stack(
              children: [
                IndexedStack(
                  index: _index,
                  children: const [
                    HomePage(),
                    AnalyticsPage(),
                    TimerPage(),
                    SettingsPage(embedded: true),
                  ],
                ),
                // Overlay (not Scaffold.bottomNavigationBar) so no fixed strip
                // blocks the canvas behind the floating notch bar.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    color: navBar,
                    notchColor: navBar,
                    showLabel: true,
                    showShadow: true,
                    shadowElevation: 8,
                    elevation: 0,
                    removeMargins: false,
                    durationInMilliSeconds: 300,
                    kIconSize: 24,
                    kBottomRadius: 28,
                    bottomBarHeight: 62,
                    itemLabelStyle:
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceOf(context),
                            ),
                    bottomBarItems: [
                      BottomBarItem(
                        inActiveItem:
                            Icon(Icons.home_outlined, color: inactive),
                        activeItem: const Icon(
                          Icons.home_rounded,
                          color: AppTheme.primary,
                        ),
                        itemLabel: l10n.navHome,
                      ),
                      BottomBarItem(
                        inActiveItem:
                            Icon(Icons.insights_outlined, color: inactive),
                        activeItem: const Icon(
                          Icons.insights_rounded,
                          color: AppTheme.primary,
                        ),
                        itemLabel: l10n.navAnalytics,
                      ),
                      BottomBarItem(
                        inActiveItem:
                            Icon(Icons.timer_outlined, color: inactive),
                        activeItem: const Icon(
                          Icons.timer_rounded,
                          color: AppTheme.primary,
                        ),
                        itemLabel: l10n.navTimer,
                      ),
                      BottomBarItem(
                        inActiveItem:
                            Icon(Icons.settings_outlined, color: inactive),
                        activeItem: const Icon(
                          Icons.settings_rounded,
                          color: AppTheme.primary,
                        ),
                        itemLabel: l10n.navSettings,
                      ),
                    ],
                    onTap: (index) {
                      setState(() => _index = index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets tab pages request a switch (e.g. Home → Settings) without a route push.
class MainShellScope extends InheritedWidget {
  /// Creates the shell scope.
  const MainShellScope({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
    required super.child,
  });

  /// Currently visible tab index.
  final int selectedIndex;

  /// Switches the visible tab.
  final ValueChanged<int> onSelectTab;

  /// Home tab index.
  static const int homeTab = 0;

  /// Analytics tab index.
  static const int analyticsTab = 1;

  /// Timer tab index.
  static const int timerTab = 2;

  /// Settings tab index.
  static const int settingsTab = 3;

  /// Returns the nearest shell scope, or null outside the shell.
  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  /// Returns the nearest shell scope; throws if missing.
  static MainShellScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'MainShellScope not found in context');
    return scope!;
  }

  /// Opens the Settings tab.
  void goToSettings() => onSelectTab(settingsTab);

  @override
  bool updateShouldNotify(MainShellScope oldWidget) {
    return selectedIndex != oldWidget.selectedIndex;
  }
}
