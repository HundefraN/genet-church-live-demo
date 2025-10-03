import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/data/services/api_service.dart';
import 'package:genet_church_portal/features/auth/presentation/login_screen.dart';
import 'app_router_deferred.dart' deferred as deferred_router;

final routerAuthRepositoryProvider = Provider((ref) => AuthRepository(
  ref.watch(dioProvider),
  const FlutterSecureStorage(),
));

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/login',
      navigatorKey: _rootNavigatorKey,
      redirect: (BuildContext context, GoRouterState state) async {
        final authRepository = ref.read(routerAuthRepositoryProvider);
        final user = await authRepository.getCurrentUser();
        final isLoggedIn = user != null;

        final isLoggingIn = state.matchedLocation == '/login';

        if (ref.read(authStateProvider) == null && isLoggedIn) {
          ref.read(authStateProvider.notifier).state = user;
        }

        if (!isLoggedIn && !isLoggingIn) return '/login';
        if (isLoggedIn && isLoggingIn) return '/dashboard';

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return FutureBuilder<void>(
              future: deferred_router.loadLibrary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final shellRoute = deferred_router.buildShellRoute();
                  final shellBuilder = shellRoute.builder;
                  return shellBuilder!(context, state, child);
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          },
          routes: [
            GoRoute(
                path: '/dashboard',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/add-church',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/add-pastors',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/permissions',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/profile',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/report-churchs',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/report-pastors',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/report-departments',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/report-servants',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/add-members',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/show-members',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/categories',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/advanced-reports',
                builder: (context, state) => const SizedBox.shrink()),
            GoRoute(
                path: '/activity-log',
                builder: (context, state) => const SizedBox.shrink()),
          ],
        ),
      ],
    );
  }
}