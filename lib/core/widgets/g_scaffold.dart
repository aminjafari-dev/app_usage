import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_usage/core/theme/app_theme.dart';

/// Shared scaffold wrapper used instead of raw [Scaffold].
///
/// How to use:
/// ```dart
/// GScaffold(
///   title: 'Home',
///   body: child,
/// );
/// ```
///
/// Keeps the soft grey canvas and light app bar consistent across pages.
class GScaffold extends StatelessWidget {
  /// Creates a themed scaffold with an optional title and actions.
  const GScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.leading,
    this.showBackButton = false,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.background;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
      ),
      child: Scaffold(
        backgroundColor: bg,
        extendBody: extendBody,
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!),
                leading: leading,
                automaticallyImplyLeading: showBackButton,
                actions: actions,
                backgroundColor: appBarBackgroundColor ?? bg,
              ),
        body: SafeArea(child: body),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
