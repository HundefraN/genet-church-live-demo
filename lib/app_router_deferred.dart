import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:genet_church_portal/features/categories_screen.dart';
import 'package:genet_church_portal/shared_widgets/main_layout.dart';

final Map<String, List<String>> routeBreadcrumbs = {
  '/dashboard': ['App', 'Dashboard'],
  '/add-church': ['App', 'Church', 'Add Church'],
  '/add-pastors': ['App', 'Pastors', 'Add Pastor'],
  '/permissions': ['App', 'Settings', 'Permissions'],
  '/profile': ['App', 'User', 'Profile'],
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

final shellNavigatorKey = GlobalKey<NavigatorState>();

ShellRoute buildShellRoute() {
  return ShellRoute(
    navigatorKey: shellNavigatorKey,
    builder: (context, state, child) {
      final breadcrumbs = routeBreadcrumbs[state.matchedLocation] ?? ['App'];
      return MainLayout(breadcrumbs: breadcrumbs, child: child);
    },
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-church',
        builder: (context, state) => const AddChurchScreen(),
      ),
      GoRoute(
        path: '/add-pastors',
        builder: (context, state) => const AddPastorsScreen(),
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
  );
}