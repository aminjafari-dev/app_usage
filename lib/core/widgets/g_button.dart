import 'package:flutter/material.dart';

import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_text.dart';

/// Primary capsule button with a soft blue drop shadow.
///
/// How to use:
/// ```dart
/// GButton(label: 'Start', onPressed: () {});
/// ```
///
/// Matches the solid blue pill CTAs from the profile designs (e.g. “Add a post”).
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
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.surface,
        disabledBackgroundColor: AppTheme.onSurfaceMuted.withValues(alpha: 0.25),
        disabledForegroundColor: AppTheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.surface,
              ),
            )
          : Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppTheme.surface),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: GText(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                    color: AppTheme.surface,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    // Soft blue glow under enabled primary CTAs.
    final shadowed = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: enabled ? AppTheme.primaryButtonShadow : null,
      ),
      child: button,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: shadowed);
    }
    return shadowed;
  }
}

/// Secondary outlined capsule button for less-emphasized actions.
///
/// Example: opening system settings from the permissions page.
class GOutlinedButton extends StatelessWidget {
  /// Creates an outlined button.
  const GOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.primary, width: 1.2),
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GText(
              label,
              style: Theme.of(context).textTheme.labelLarge,
              color: AppTheme.primary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
