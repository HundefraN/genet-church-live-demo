import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/analytics_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:genet_church_portal/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:genet_church_portal/shared_widgets/responsive_layout.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return const ResponsiveLayout(
          mobileBody: _DashboardMobileLayout(),
          desktopBody: _DashboardDesktopLayout(),
        );
      },
      loading: () => const _DashboardLoadingShimmer(),
      error: (error, stackTrace) => Center(
        child: Text('Failed to load dashboard data: $error'),
      ),
    );
  }
}

class _DashboardDesktopLayout extends StatelessWidget {
  const _DashboardDesktopLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        Row(
          children: const [
            Expanded(child: ChurchesStatCard()),
            SizedBox(width: 24),
            Expanded(child: PastorsStatCard()),
            SizedBox(width: 24),
            Expanded(child: MembersStatCard()),
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
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut);
  }
}

class _DashboardMobileLayout extends StatelessWidget {
  const _DashboardMobileLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: const [
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
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut);
  }
}

class _DashboardLoadingShimmer extends StatelessWidget {
  const _DashboardLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: const ResponsiveLayout(
          mobileBody: _ShimmerMobile(),
          desktopBody: _ShimmerDesktop(),
        ));
  }
}

class _ShimmerDesktop extends StatelessWidget {
  const _ShimmerDesktop();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(width: 24),
            Expanded(
                child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(width: 24),
            Expanded(
                child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 2,
                child: Container(
                    height: 600,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(width: 24),
            Expanded(
                flex: 3,
                child: Container(
                    height: 800,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)))),
          ],
        )
      ],
    );
  }
}

class _ShimmerMobile extends StatelessWidget {
  const _ShimmerMobile();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 120,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12))),
        const SizedBox(height: 16),
        Container(
            height: 120,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12))),
        const SizedBox(height: 16),
        Container(
            height: 120,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12))),
        const SizedBox(height: 24),
        Container(
            height: 600,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ],
    );
  }
}