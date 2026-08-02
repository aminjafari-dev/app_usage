import 'package:flutter/material.dart';

import 'package:app_usage/core/router/page_name.dart';
import 'package:app_usage/features/app_usage/presentation/pages/permissions_page.dart';
import 'package:app_usage/features/app_usage/presentation/pages/unsupported_page.dart';
import 'package:app_usage/features/navigation/presentation/pages/main_shell_page.dart';
import 'package:app_usage/features/settings/presentation/pages/settings_page.dart';

/// Central registry of named routes for the app.
///
/// How to use:
/// ```dart
/// MaterialApp(routes: PageRouter.routes, initialRoute: PageName.home);
/// ```
class PageRouter {
  PageRouter._();

  /// All route mappings. Pages must be registered here with [PageName] keys.
  static Map<String, WidgetBuilder> routes = {
    PageName.home: (context) => const MainShellPage(),
    PageName.permissions: (context) => const PermissionsPage(),
    PageName.unsupported: (context) => const UnsupportedPage(),
    PageName.settings: (context) => const SettingsPage(),
  };
}
