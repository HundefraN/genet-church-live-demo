import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/analytics_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/departments_overview_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:genet_church_portal/shared_widgets/responsive_layout.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final user = ref.watch(authStateProvider);

    // FIX: Explicitly watch the timeframe provider here to force this widget tree to rebuild
    // when the filter changes.
    ref.watch(dashboardTimeframeProvider);

    // Also invalidate the stats provider when this screen builds if timeframe changed,
    // ensuring data is re-fetched.
    ref.listen(dashboardTimeframeProvider, (previous, next) {
      if (previous != next) {
        ref.invalidate(dashboardStatsProvider);
      }
    });

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget statCards;
    if (user.roleEnum == UserRole.SUPER_ADMIN) {
      statCards = const Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.spaceEvenly,
        children: [ChurchesStatCard(), PastorsStatCard(), MembersStatCard()],
      );
    } else if (user.roleEnum == UserRole.PASTOR) {
      statCards = const Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          MembersStatCard(),
          ServantsStatCard(),
          DepartmentsStatCard(),
        ],
      );
    } else {
      statCards = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            "Welcome to the Genet Church Portal!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      color: appColors.scaffold,
      child: ResponsiveLayout(
        mobileBody: _DashboardMobileLayout(statCards: statCards),
        desktopBody: _DashboardDesktopLayout(statCards: statCards),
      ),
    );
  }
}

class _TimeframeSelector extends ConsumerWidget {
  const _TimeframeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeframe = ref.watch(dashboardTimeframeProvider);
    final appColors = Theme.of(context).extension<AppColors>()!;
    // Watch stats async value to show loading state on buttons if needed
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isLoading = statsAsync.isLoading;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimeframeButton(
            label: '7 Days',
            value: '7d',
            isSelected: selectedTimeframe == '7d',
            isLoading: isLoading && selectedTimeframe == '7d',
            onTap: () {
              if (!isLoading)
                ref.read(dashboardTimeframeProvider.notifier).state = '7d';
            },
          ),
          _TimeframeButton(
            label: '30 Days',
            value: '30d',
            isSelected: selectedTimeframe == '30d',
            isLoading: isLoading && selectedTimeframe == '30d',
            onTap: () {
              if (!isLoading)
                ref.read(dashboardTimeframeProvider.notifier).state = '30d';
            },
          ),
          _TimeframeButton(
            label: '1 Year',
            value: '1y',
            isSelected: selectedTimeframe == '1y',
            isLoading: isLoading && selectedTimeframe == '1y',
            onTap: () {
              if (!isLoading)
                ref.read(dashboardTimeframeProvider.notifier).state = '1y';
            },
          ),
          _TimeframeButton(
            label: 'All Time',
            value: 'all',
            isSelected: selectedTimeframe == 'all',
            isLoading: isLoading && selectedTimeframe == 'all',
            onTap: () {
              if (!isLoading)
                ref.read(dashboardTimeframeProvider.notifier).state = 'all';
            },
          ),
        ],
      ),
    );
  }
}

class _TimeframeButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  const _TimeframeButton({
    required this.label,
    required this.value,
    required this.isSelected,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : appColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(width: 6),
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GreetingWidget extends ConsumerWidget {
  const _GreetingWidget();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
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
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, curve: Curves.easeOut),
              if (!isSmallScreen) ...[
                const SizedBox(height: 8),
                Text(
                      "Here's your portal's overview for today.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: appColors.textSecondary,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: -0.2, curve: Curves.easeOut),
              ],
            ],
          ),
          if (!isSmallScreen) const _TimeframeSelector(),
        ],
      ),
    );
  }
}

class _DashboardDesktopLayout extends StatelessWidget {
  final Widget statCards;
  const _DashboardDesktopLayout({required this.statCards});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      color: appColors.scaffold,
      child:
          ListView(
                padding: const EdgeInsets.all(24.0),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  const _GreetingWidget(),
                  statCards,
                  const SizedBox(height: 24),
                  // Show Departments Overview for Pastors
                  if (Theme.of(context).extension<AppColors>() !=
                      null) // Just a check to access context safely if needed
                    const DepartmentsOverviewCard(),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 2, child: RecentActivityCard()),
                      SizedBox(width: 24),
                      Expanded(flex: 3, child: AnalyticsCard()),
                    ],
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }
}

class _DashboardMobileLayout extends StatelessWidget {
  final Widget statCards;
  const _DashboardMobileLayout({required this.statCards});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      color: appColors.scaffold,
      child:
          ListView(
                padding: const EdgeInsets.all(16.0),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  const _GreetingWidget(),
                  const SizedBox(height: 16),
                  const Center(child: _TimeframeSelector()),
                  const SizedBox(height: 24),
                  if (statCards is Wrap)
                    ...(statCards as Wrap).children
                        .expand(
                          (widget) => [widget, const SizedBox(height: 16)],
                        )
                        .toList()
                      ..removeLast()
                  else
                    statCards,
                  const SizedBox(height: 24),
                  const DepartmentsOverviewCard(),
                  const SizedBox(height: 24),
                  const RecentActivityCard(),
                  const SizedBox(height: 24),
                  const AnalyticsCard(),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }
}
