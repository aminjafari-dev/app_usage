import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/features/app_usage/presentation/pages/home_page.dart';
import 'package:app_usage/features/app_usage/presentation/pages/profile_page.dart';
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
class MainShellPage extends StatefulWidget {
  /// Creates the main tab shell.
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  int _index = 0;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                  TimerPage(),
                  SettingsPage(embedded: true),
                  ProfilePage(),
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
                  showShadow: false,
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
                    BottomBarItem(
                      inActiveItem: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primarySoft,
                        child: Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: inactive,
                        ),
                      ),
                      activeItem: const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primarySoft,
                        child: Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      itemLabel: l10n.navProfile,
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

  /// Timer tab index.
  static const int timerTab = 1;

  /// Settings tab index.
  static const int settingsTab = 2;

  /// Profile tab index.
  static const int profileTab = 3;

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
