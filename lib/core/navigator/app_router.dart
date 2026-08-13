import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const _AppShell(),
      ),
    ],
  );
}

final class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Store App')));
  }
}
