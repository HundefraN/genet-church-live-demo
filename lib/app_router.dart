import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/data/services/api_service.dart';
import 'package:genet_church_portal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:genet_church_portal/features/screens/activity_log_screen.dart';
import 'package:genet_church_portal/features/screens/add_church_screen.dart';
import 'package:genet_church_portal/features/screens/add_members_screen.dart';
import 'package:genet_church_portal/features/screens/add_pastors_screen.dart';
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

final routerAuthRepositoryProvider = Provider((ref) => AuthRepository(
  ref.watch(dioProvider),
  const FlutterSecureStorage(),
));

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
            List<String> breadcrumbs = ['GCD'];
            final location = state.uri.toString();

            if (location.contains('dashboard'))
              breadcrumbs = ['App', 'Dashboard'];
            if (location.contains('church')) breadcrumbs.add('Church');
            if (location.contains('pastors')) breadcrumbs.add('Pastors');
            if (location.contains('departments'))
              breadcrumbs.add('Departments');
            if (location.contains('servants')) breadcrumbs.add('Servants');
            if (location.contains('add-church')) breadcrumbs.add('Add Church');
            if (location.contains('add-pastors'))
              breadcrumbs.add('Add Pastor');
            if (location.contains('permissions'))
              breadcrumbs.add('Permission');
            if (location.contains('profile')) breadcrumbs.add('Profile');
            if (location.contains('report')) breadcrumbs.add('Report');
            if (location.contains('report-churchs')) breadcrumbs.add('Church');
            if (location.contains('report-pastors'))
              breadcrumbs.add('Pastors');
            if (location.contains('report-departments'))
              breadcrumbs.add('Departments');
            if (location.contains('report-servants'))
              breadcrumbs.add('Servants');
            if (location.contains('show-members'))
              breadcrumbs.add('Show Members');
            if (location.contains('add-members')) breadcrumbs.add('Add Members');
            if (location.contains('categories')) breadcrumbs.add('Categories');
            if (location.contains('advanced-reports'))
              breadcrumbs.add('Analytics');
            if (location.contains('activity-log'))
              breadcrumbs.add('Activity Log');

            return MainLayout(breadcrumbs: breadcrumbs, child: child);
          },
          routes: [
            GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen()),
            GoRoute(
                path: '/add-church',
                builder: (context, state) => const AddChurchScreen()),
            GoRoute(
                path: '/add-pastors',
                builder: (context, state) => const AddPastorsScreen()),
            GoRoute(
                path: '/permissions',
                builder: (context, state) => const PermissionsScreen()),
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen()),
            GoRoute(
                path: '/report-churchs',
                builder: (context, state) => const ReportChurchsScreen()),
            GoRoute(
                path: '/report-pastors',
                builder: (context, state) => const ReportPastorsScreen()),
            GoRoute(
                path: '/report-departments',
                builder: (context, state) => const ReportDepartmentsScreen()),
            GoRoute(
                path: '/report-servants',
                builder: (context, state) => const ReportServantsScreen()),
            GoRoute(
                path: '/add-members',
                builder: (context, state) => const AddMembersScreen()),
            GoRoute(
                path: '/show-members',
                builder: (context, state) => const ShowMembersScreen()),
            GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesScreen()),
            GoRoute(
                path: '/advanced-reports',
                builder: (context, state) => const AdvancedReportsScreen()),
            GoRoute(
                path: '/activity-log',
                builder: (context, state) => const ActivityLogScreen()),
            // GoRoute(
            //     path: '/communication-hub',
            //     builder: (context, state) => const CommunicationHubScreen()),
          ],
        ),
      ],
    );
  }
}