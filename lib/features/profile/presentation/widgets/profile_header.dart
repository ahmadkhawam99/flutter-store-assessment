import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.username, required this.email, super.key});

  final String username;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          key: const ValueKey('profile-avatar'),
          width: 84.r,
          height: 84.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _initialFor(username),
                key: const ValueKey('profile-avatar-initial'),
                style: context.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          username,
          key: const ValueKey('profile-hero-username'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge,
        ),
        SizedBox(height: 6.h),
        Text(
          email,
          key: const ValueKey('profile-hero-email'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge,
        ),
      ],
    );
  }

  String _initialFor(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? '?' : normalized.substring(0, 1).toUpperCase();
  }
}
