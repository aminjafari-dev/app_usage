import 'package:flutter/material.dart';

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
/// Keeps AppBar styling and background consistent across pages.
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
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: leading,
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
