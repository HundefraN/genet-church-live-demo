import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/data/services/api_service.dart';
import 'package:genet_church_portal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:genet_church_portal/features/screens/activity_log_screen.dart';
import 'package:genet_church_portal/features/screens/add_members_screen.dart';
import 'package:genet_church_portal/features/screens/advanced_reports_screen.dart';
import 'package:genet_church_portal/features/screens/permissions_screen.dart';
import 'package:genet_church_portal/features/screens/profile_screen.dart';
import 'package:genet_church_portal/features/screens/report_churchs_screen.dart';
import 'package:genet_church_portal/features/screens/report_departments_screen.dart';
import 'package:genet_church_portal/features/screens/report_pastors_screen.dart';
import 'package:genet_church_portal/features/screens/report_servants_screen.dart';
import 'package:genet_church_portal/features/screens/show_members_screen.dart';
import 'package:genet_church_portal/shared_widgets/main_layout.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/categories_screen.dart';
import 'features/screens/lib/features/screens/sessions_screen.dart';

final routerAuthRepositoryProvider = Provider((ref) => AuthRepository(
  ref.watch(dioProvider),
  const FlutterSecureStorage(),
));

final Map<String, List<String>> _routeBreadcrumbs = {
  '/dashboard': ['App', 'Dashboard'],
  '/permissions': ['App', 'Settings', 'Permissions'],
  '/profile': ['App', 'User', 'Profile'],
  '/sessions': ['App', 'User', 'Security'],
  '/report-churchs': ['App', 'Church', 'Reports'],
  '/report-pastors': ['App', 'Pastors', 'Reports'],
  '/report-departments': ['App', 'Departments', 'Reports'],
  '/report-servants': ['App', 'Servants', 'Reports'],
  '/add-members': ['App', 'Members', 'Add Member'],
  '/show-members': ['App', 'Members', 'Show Members'],
  '/categories': ['App', 'Members', 'Categories'],
  '/advanced-reports': ['App', 'Analytics'],
  '/activity-log': ['App', 'System', 'Activity Log'],
};

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            final breadcrumbs =
                _routeBreadcrumbs[state.matchedLocation] ?? ['App'];
            return MainLayout(breadcrumbs: breadcrumbs, child: child);
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/permissions',
              builder: (context, state) => const PermissionsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/sessions',
              builder: (context, state) => const SessionsScreen(),
            ),
            GoRoute(
              path: '/report-churchs',
              builder: (context, state) => const ReportChurchsScreen(),
            ),
            GoRoute(
              path: '/report-pastors',
              builder: (context, state) => const ReportPastorsScreen(),
            ),
            GoRoute(
              path: '/report-departments',
              builder: (context, state) => const ReportDepartmentsScreen(),
            ),
            GoRoute(
              path: '/report-servants',
              builder: (context, state) => const ReportServantsScreen(),
            ),
            GoRoute(
              path: '/add-members',
              builder: (context, state) => const AddMembersScreen(),
            ),
            GoRoute(
              path: '/show-members',
              builder: (context, state) => const ShowMembersScreen(),
            ),
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesScreen(),
            ),
            GoRoute(
              path: '/advanced-reports',
              builder: (context, state) => const AdvancedReportsScreen(),
            ),
            GoRoute(
              path: '/activity-log',
              builder: (context, state) => const ActivityLogScreen(),
            ),
          ],
        ),
      ],
    );
  }
}