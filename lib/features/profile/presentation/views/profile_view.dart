import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigator/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/auth_session_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_tile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: AppColors.background,
          key: const ValueKey('profile-back-button'),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.homeName);
            }
          },
        ),
        title: const Text('My Account'),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => switch (state) {
            Authenticated(:final session) => _AuthenticatedProfile(
              session: session,
              onLogoutPressed: () => _confirmLogout(context),
            ),
            AuthInitial() || AuthChecking() => const _ProfileLoading(),
            AuthFailure() => const _ProfileUnavailable(
              message: 'We could not load your account right now.',
            ),
            Unauthenticated() => const _ProfileUnavailable(
              message: 'Your session is no longer available.',
            ),
          },
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey('profile-logout-dialog'),
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            key: const ValueKey('profile-logout-cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('profile-logout-confirm'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequestedEvent());
    }
  }
}

class _AuthenticatedProfile extends StatelessWidget {
  const _AuthenticatedProfile({
    required this.session,
    required this.onLogoutPressed,
  });

  final AuthSessionEntity session;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 700 ? 32.0 : 20.w;

        return SingleChildScrollView(
          key: const ValueKey('profile-scroll'),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            20.h,
            horizontalPadding,
            24.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(
                    username: session.username,
                    email: session.email,
                  ),
                  SizedBox(height: 34.h),
                  Text(
                    'Account Information',
                    style: context.textTheme.titleMedium,
                  ),
                  SizedBox(height: 16.h),
                  ProfileInfoTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Username',
                    value: session.username,
                    valueKey: const ValueKey('profile-username-value'),
                  ),
                  SizedBox(height: 12.h),
                  ProfileInfoTile(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                    value: session.email,
                    valueKey: const ValueKey('profile-email-value'),
                  ),
                  SizedBox(height: 30.h),
                  OutlinedButton.icon(
                    key: const ValueKey('profile-logout-button'),
                    onPressed: onLogoutPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      backgroundColor: AppColors.error.withValues(alpha: 0.04),
                      minimumSize: Size.fromHeight(54.h),
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.32),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    icon: Icon(Icons.logout_rounded, size: 21.r),
                    label: const Text('Log out'),
                  ),
                  // The shell may overlay its 68.r cart control 32.h from the
                  // bottom when the cart is non-empty.
                  SizedBox(height: 68.r + 32.h + 12.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('profile-loading'),
      child: SizedBox.square(
        dimension: 28.r,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _ProfileUnavailable extends StatelessWidget {
  const _ProfileUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('profile-unavailable'),
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
