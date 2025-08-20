import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/features/dashboard/presentation/dashboard_screen.dart';
import 'package:genet_church_portal/features/screens/add_church_screen.dart';
import 'package:genet_church_portal/features/screens/add_members_screen.dart';
import 'package:genet_church_portal/features/screens/add_pastors_screen.dart';
import 'package:genet_church_portal/features/screens/advanced_reports_screen.dart';
import 'package:genet_church_portal/features/screens/communication_hub_screen.dart';
import 'package:genet_church_portal/features/screens/permissions_screen.dart';
import 'package:genet_church_portal/features/screens/report_churchs_screen.dart';
import 'package:genet_church_portal/features/screens/report_pastors_screen.dart';
import 'package:genet_church_portal/features/screens/show_members_screen.dart';
import 'package:genet_church_portal/shared_widgets/main_layout.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/categories_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
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

          if (location.contains('dashboard')) breadcrumbs = ['App', 'Dashboard'];
          if (location.contains('church')) breadcrumbs.add('Church');
          if (location.contains('pastors')) breadcrumbs.add('Pastors');
          if (location.contains('add-church')) breadcrumbs.add('Add Church');
          if (location.contains('add-pastors')) breadcrumbs.add('Add Pastor');
          if (location.contains('permissions')) breadcrumbs.add('Permission');
          if (location.contains('report')) breadcrumbs.add('Report');
          if (location.contains('report-churchs')) breadcrumbs.add('Church');
          if (location.contains('report-pastors')) breadcrumbs.add('Report');
          if (location.contains('show-members')) breadcrumbs.add('Show Members');
          if (location.contains('add-members')) breadcrumbs.add('Add Members');
          if (location.contains('categories')) breadcrumbs.add('Categories');
          if (location.contains('advanced-reports')) breadcrumbs.add('Analytics');
          if (location.contains('communication-hub')) breadcrumbs.add('Communication');

          return MainLayout(breadcrumbs: breadcrumbs, child: child);
        },
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/add-church', builder: (context, state) => const AddChurchScreen()),
          GoRoute(path: '/add-pastors', builder: (context, state) => const AddPastorsScreen()),
          GoRoute(path: '/permissions', builder: (context, state) => const PermissionsScreen()),
          GoRoute(path: '/report-churchs', builder: (context, state) => const ReportChurchsScreen()),
          GoRoute(path: '/report-pastors', builder: (context, state) => const ReportPastorsScreen()),
          GoRoute(path: '/add-members', builder: (context, state) => const AddMembersScreen()),
          GoRoute(path: '/show-members', builder: (context, state) => const ShowMembersScreen()),
          GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
          GoRoute(path: '/advanced-reports', builder: (context, state) => const AdvancedReportsScreen()),
          GoRoute(path: '/communication-hub', builder: (context, state) => const CommunicationHubScreen()),
        ],
      ),
    ],
  );
}