import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import 'pages/authenticated_shell_page.dart';
import 'routes.dart';

abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        pageBuilder: (context, state) =>
            _page(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signInName,
        pageBuilder: (context, state) =>
            _page(state: state, child: const SignInPage()),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.signUpName,
        pageBuilder: (context, state) =>
            _page(state: state, child: const SignUpPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AuthenticatedShellPage(
          key: const ValueKey('authenticated-shell'),
          currentRouteName: state.topRoute?.name,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            pageBuilder: (context, state) =>
                _authenticatedPage(state: state, child: const HomePage()),
            routes: [
              GoRoute(
                path: AppRoutes.productDetails,
                name: AppRoutes.productDetailsName,
                pageBuilder: (context, state) {
                  final productId = int.tryParse(
                    state.pathParameters[AppRoutes.productIdParameter] ?? '',
                  );
                  return _authenticatedPage(
                    state: state,
                    child: productId == null || productId <= 0
                        ? const _InvalidProductPage()
                        : ProductDetailsPage(productId: productId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: AppRoutes.cartName,
            pageBuilder: (context, state) =>
                _authenticatedPage(state: state, child: const CartPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: AppRoutes.profileName,
            pageBuilder: (context, state) =>
                _authenticatedPage(state: state, child: const ProfilePage()),
          ),
        ],
      ),
    ],
  );

  static CustomTransitionPage<void> _page({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static CustomTransitionPage<void> _authenticatedPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.025, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _InvalidProductPage extends StatelessWidget {
  const _InvalidProductPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: Text('This product ID is invalid.')),
            Positioned(
              top: 8,
              left: 12,
              child: BackButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(AppRoutes.homeName);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
