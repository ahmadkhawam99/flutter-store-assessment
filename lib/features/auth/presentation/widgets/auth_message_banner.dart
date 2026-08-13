import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

abstract final class AuthMessageBanner {
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFFFF1F0),
      foregroundColor: AppColors.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: const Color(0xFFECFDF3),
      foregroundColor: const Color(0xFF027A48),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          backgroundColor: backgroundColor,
          leading: Icon(icon, color: foregroundColor),
          content: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Dismiss message',
              onPressed: messenger.hideCurrentMaterialBanner,
              icon: Icon(Icons.close_rounded, color: foregroundColor),
            ),
          ],
        ),
      );
  }
}
