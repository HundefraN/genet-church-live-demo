import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/analytics_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:genet_church_portal/shared_widgets/responsive_layout.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      color: appColors.scaffold,
      child: const ResponsiveLayout(
        mobileBody: _DashboardMobileLayout(),
        desktopBody: _DashboardDesktopLayout(),
      ),
    );
  }
}

class _GreetingWidget extends ConsumerWidget {
  const _GreetingWidget();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final userName = user?.fullName.split(' ').first ?? 'User';
    final greeting = _getGreeting();
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 24.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $userName!',
            style: isSmallScreen
                ? theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: appColors.textPrimary,
            )
                : theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: appColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, curve: Curves.easeOut),
          if (!isSmallScreen) ...[
            const SizedBox(height: 8),
            Text(
              "Here's your portal's overview for today.",
              style: theme.textTheme.titleMedium?.copyWith(
                color: appColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.2, curve: Curves.easeOut),
          ]
        ],
      ),
    );
  }
}

class _DashboardDesktopLayout extends StatelessWidget {
  const _DashboardDesktopLayout();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      color: appColors.scaffold,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          const _GreetingWidget(),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.spaceEvenly,
            children: const [
              ChurchesStatCard(),
              PastorsStatCard(),
              MembersStatCard(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 2, child: RecentActivityCard()),
              SizedBox(width: 24),
              Expanded(flex: 3, child: AnalyticsCard()),
            ],
          )
        ],
      ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }
}

class _DashboardMobileLayout extends StatelessWidget {
  const _DashboardMobileLayout();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      color: appColors.scaffold,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: const [
          _GreetingWidget(),
          ChurchesStatCard(),
          SizedBox(height: 16),
          PastorsStatCard(),
          SizedBox(height: 16),
          MembersStatCard(),
          SizedBox(height: 24),
          RecentActivityCard(),
          SizedBox(height: 24),
          AnalyticsCard(),
        ],
      ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }
}