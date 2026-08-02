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
    this.centerTitle = false,
    this.circularBackButton = false,
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
  final bool centerTitle;
  final bool circularBackButton;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.canvasOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = (isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: bg,
    );

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && circularBackButton) {
      resolvedLeading = const _CircularBackButton();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: bg,
        extendBody: extendBody,
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!),
                leading: resolvedLeading,
                automaticallyImplyLeading:
                    showBackButton && resolvedLeading == null,
                centerTitle: centerTitle,
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

/// Soft circular chevron used on settings-style screens.
class _CircularBackButton extends StatelessWidget {
  const _CircularBackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Center(
        child: Material(
          color: AppTheme.surfaceOf(context),
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.dividerOf(context)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppTheme.onSurfaceOf(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
