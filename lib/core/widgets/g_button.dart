import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_text.dart';

/// Primary button used across the app instead of raw ElevatedButton.
///
/// How to use:
/// ```dart
/// GButton(label: 'Start', onPressed: () {});
/// ```
class GButton extends StatelessWidget {
  /// Creates a filled primary button.
  ///
  /// When [onPressed] is null the button is disabled, which is useful while
  /// waiting for permissions or loading states.
  const GButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.surface,
        disabledBackgroundColor: AppTheme.onSurfaceMuted.withValues(alpha: 0.3),
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : GText(
              label,
              style: Theme.of(context).textTheme.labelLarge,
              color: AppTheme.surface,
            ),
    );

    // Expand by default so forms and permission screens look balanced.
    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Secondary outlined button for less-emphasized actions.
///
/// Example: opening system settings from the permissions page.
class GOutlinedButton extends StatelessWidget {
  /// Creates an outlined button.
  const GOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.primary),
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: GText(
        label,
        style: Theme.of(context).textTheme.labelLarge,
        color: AppTheme.primary,
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
