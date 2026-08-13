import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/core/theme/app_theme.dart';

import '../../../../core/navigator/routes.dart';
import '../../../../core/widgets/image/app_image.dart';
import '../../../auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _minimumDisplayTimer;
  bool _isVisible = false;
  bool _minimumDisplayComplete = false;
  bool _hasNavigated = false;
  AuthState? _authState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
        _authState = context.read<AuthBloc>().state;
        _tryNavigate();
      }
    });

    _minimumDisplayTimer = Timer(const Duration(milliseconds: 950), () {
      if (mounted) {
        _minimumDisplayComplete = true;
        _tryNavigate();
      }
    });
  }

  @override
  void dispose() {
    _minimumDisplayTimer?.cancel();
    super.dispose();
  }

  void _tryNavigate() {
    if (!_minimumDisplayComplete || _hasNavigated || !mounted) return;
    final state = _authState;
    if (state is Authenticated) {
      _hasNavigated = true;
      context.goNamed(AppRoutes.homeName);
    } else if (state is Unauthenticated || state is AuthFailure) {
      _hasNavigated = true;
      context.goNamed(AppRoutes.signInName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _authState = state;
        _tryNavigate();
      },
      child: Scaffold(
        body: Center(
          child: AnimatedOpacity(
            opacity: _isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            child: AnimatedScale(
              scale: _isVisible ? 1 : 0.97,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: SizedBox(
                width: 230.w,
                height: 190.h,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      bottom: 18.h,
                      child: AppImage(
                        key: const ValueKey('splash-logo-text'),
                        assetPath: 'assets/images/logo-text.png',
                        width: 165.w,
                        fit: BoxFit.contain,
                        semanticLabel: 'Store App',
                      ),
                    ),

                    Positioned(
                      top: 0,
                      child: SizedBox(
                        width: 180.w,
                        height: 110.h,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: -1.0, end: 0.0),
                          duration: const Duration(milliseconds: 950),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(value * 100.w, 0),
                              child: child,
                            );
                          },
                          child: AppImage(
                            key: const ValueKey('splash-cart'),
                            assetPath: 'assets/images/cart-image.png',
                            width: 78.w,
                            fit: BoxFit.contain,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
