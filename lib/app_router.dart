import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/data/services/api_service.dart';
import 'package:genet_church_portal/shared_widgets/deferred_loader.dart';
import 'package:genet_church_portal/shared_widgets/main_layout.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/auth/presentation/login_screen.dart' deferred as login_screen;
import 'features/dashboard/presentation/dashboard_screen.dart' deferred as dashboard_screen;
import 'features/screens/activity_log_screen.dart' deferred as activity_log_screen;
import 'features/screens/add_church_screen.dart' deferred as add_church_screen;
import 'features/screens/add_members_screen.dart' deferred as add_members_screen;
import 'features/screens/add_pastors_screen.dart' deferred as add_pastors_screen;
import 'features/screens/advanced_reports_screen.dart' deferred as advanced_reports_screen;
import 'features/settings/presentation/settings_screen.dart' deferred as settings_screen;
import 'features/screens/profile_screen.dart' deferred as profile_screen;
import 'features/screens/report_churchs_screen.dart' deferred as report_churchs_screen;
import 'features/screens/report_departments_screen.dart' deferred as report_departments_screen;
import 'features/screens/report_pastors_screen.dart' deferred as report_pastors_screen;
import 'features/screens/report_servants_screen.dart' deferred as report_servants_screen;
import 'features/screens/show_members_screen.dart' deferred as show_members_screen;
import 'features/screens/members_detail_screen.dart' deferred as members_detail_screen;
import 'features/screens/sessions_screen.dart' deferred as sessions_screen;

part 'app_router.g.dart';

final routerAuthRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);

final Map<String, List<String>> _routeBreadcrumbs = {
  '/dashboard': ['App', 'Dashboard'],
  '/settings': ['App', 'Settings'],
  '/profile': ['App', 'User', 'Profile'],
  '/sessions': ['App', 'User', 'Security'],
  '/report-churchs': ['App', 'Church', 'Reports'],
  '/add-church': ['App', 'Church', 'Add Church'],
  '/report-pastors': ['App', 'Pastors', 'Reports'],
  '/add-pastors': ['App', 'Pastors', 'Add Pastor'],
  '/departments': ['App', 'Departments', 'Reports'],
  '/report-servants': ['App', 'Servants', 'Reports'],
  '/add-members': ['App', 'Members', 'Add Member'],
  '/show-members': ['App', 'Members', 'Show Members'],
  '/show-members/:memberId': ['App', 'Members', 'Member Details'],

  '/advanced-reports': ['App', 'Analytics'],
  '/activity-log': ['App', 'System', 'Activity Log'],
};

const _superAdminOnlyRoutes = [
  '/report-churchs',
  '/add-church',
  '/report-pastors',
  '/add-pastors',
  '/advanced-reports',
];

const _pastorOnlyRoutes = [];

const _pastorAndServantRoutes = ['/add-members'];

@riverpod
GoRouter appRouter(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: rootNavigatorKey,
    redirect: (BuildContext context, GoRouterState state) async {
      final authRepository = ref.read(routerAuthRepositoryProvider);
      final userFromRepo = await authRepository.getCurrentUser();
      final userFromState = ref.read(authStateProvider);

      final user = userFromState ?? userFromRepo;
      final isLoggedIn = user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (userFromState == null && userFromRepo != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authStateProvider.notifier).updateUser(userFromRepo);
        });
      }

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      if (isLoggedIn) {
        final role = user.roleEnum;
        final path = state.matchedLocation;

        if (role != UserRole.SUPER_ADMIN &&
            _superAdminOnlyRoutes.any((route) => path.startsWith(route))) {
          return '/dashboard';
        }
        if (role != UserRole.PASTOR &&
            _pastorOnlyRoutes.any((route) => path.startsWith(route))) {
          return '/dashboard';
        }
        if (role == UserRole.SUPER_ADMIN &&
            _pastorAndServantRoutes.any((route) => path.startsWith(route))) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => DeferredLoader(
          loader: login_screen.loadLibrary,
          builder: (_) => login_screen.LoginScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          final breadcrumbs =
              _routeBreadcrumbs[state.matchedLocation] ?? ['App'];
          return MainLayout(breadcrumbs: breadcrumbs, child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DeferredLoader(
              loader: dashboard_screen.loadLibrary,
              builder: (_) => dashboard_screen.DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => DeferredLoader(
              loader: settings_screen.loadLibrary,
              builder: (_) => settings_screen.SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => DeferredLoader(
              loader: profile_screen.loadLibrary,
              builder: (_) => profile_screen.ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/sessions',
            builder: (context, state) => DeferredLoader(
              loader: sessions_screen.loadLibrary,
              builder: (_) => sessions_screen.SessionsScreen(),
            ),
          ),
          GoRoute(
            path: '/report-churchs',
            builder: (context, state) => DeferredLoader(
              loader: report_churchs_screen.loadLibrary,
              builder: (_) => report_churchs_screen.ReportChurchsScreen(),
            ),
          ),
          GoRoute(
            path: '/add-church',
            builder: (context, state) => DeferredLoader(
              loader: add_church_screen.loadLibrary,
              builder: (_) => add_church_screen.AddChurchScreen(),
            ),
          ),
          GoRoute(
            path: '/report-pastors',
            builder: (context, state) => DeferredLoader(
              loader: report_pastors_screen.loadLibrary,
              builder: (_) => report_pastors_screen.ReportPastorsScreen(),
            ),
          ),
          GoRoute(
            path: '/add-pastors',
            builder: (context, state) => DeferredLoader(
              loader: add_pastors_screen.loadLibrary,
              builder: (_) => add_pastors_screen.AddPastorsScreen(),
            ),
          ),
          GoRoute(
            path: '/departments',
            builder: (context, state) => DeferredLoader(
              loader: report_departments_screen.loadLibrary,
              builder: (_) => report_departments_screen.ReportDepartmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/report-servants',
            builder: (context, state) => DeferredLoader(
              loader: report_servants_screen.loadLibrary,
              builder: (_) => report_servants_screen.ReportServantsScreen(),
            ),
          ),
          GoRoute(
            path: '/add-members',
            builder: (context, state) => DeferredLoader(
              loader: add_members_screen.loadLibrary,
              builder: (_) => add_members_screen.AddMembersScreen(),
            ),
          ),
          GoRoute(
            path: '/show-members',
            builder: (context, state) => DeferredLoader(
              loader: show_members_screen.loadLibrary,
              builder: (_) => show_members_screen.ShowMembersScreen(),
            ),
          ),
          GoRoute(
            path: '/show-members/:memberId',
            builder: (context, state) {
              final memberId = state.pathParameters['memberId']!;
              return DeferredLoader(
                loader: members_detail_screen.loadLibrary,
                builder: (_) => members_detail_screen.MemberDetailsScreen(memberId: memberId),
              );
            },
          ),
          GoRoute(
            path: '/advanced-reports',
            builder: (context, state) => DeferredLoader(
              loader: advanced_reports_screen.loadLibrary,
              builder: (_) => advanced_reports_screen.AdvancedReportsScreen(),
            ),
          ),
          GoRoute(
            path: '/activity-log',
            builder: (context, state) => DeferredLoader(
              loader: activity_log_screen.loadLibrary,
              builder: (_) => activity_log_screen.ActivityLogScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}