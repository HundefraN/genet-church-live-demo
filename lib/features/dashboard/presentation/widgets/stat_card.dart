import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/dashboard_model.dart';
import 'package:genet_church_portal/data/models/pastor_dashboard_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

class ChurchesStatCard extends ConsumerWidget {
  const ChurchesStatCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return statsAsync.when(
      data: (stats) {
        if (stats is! SuperAdminDashboardStats) return const SizedBox.shrink();
        return _StatCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          onTap: () => context.go('/report-churchs'),
          value: stats.totals.totalChurches.toString(),
          label: 'Total Churches',
          icon: Iconsax.building,
          chart: _buildPieChart(),
        );
      },
      loading: () => const _StatCardLoading(),
      error: (e, s) => _StatCardError(label: 'Churches'),
    );
  }
}

class PastorsStatCard extends ConsumerWidget {
  const PastorsStatCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return statsAsync.when(
      data: (stats) {
        if (stats is! SuperAdminDashboardStats) return const SizedBox.shrink();
        return _StatCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          ),
          onTap: () => context.go('/report-pastors'),
          value: '${stats.totals.totalPastors}',
          subtitle: '${stats.totals.totalChurches} Churches Assigned',
          label: 'Total Pastors',
          icon: Iconsax.user_octagon,
          chart: _buildBarChart(stats.totals.totalPastors.toDouble()),
        );
      },
      loading: () => const _StatCardLoading(),
      error: (e, s) => _StatCardError(label: 'Pastors'),
    );
  }
}

class MembersStatCard extends ConsumerWidget {
  const MembersStatCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return statsAsync.when(
      data: (stats) {
        String value = '0';
        String label = 'Members';

        if (stats is SuperAdminDashboardStats) {
          value = stats.totals.totalMembers.toString();
          label = 'Total Members';
        } else if (stats is PastorDashboardStats) {
          value = stats.totals.totalMembers.toString();
          label = 'Your Members';
        }

        return _StatCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          ),
          onTap: () => context.go('/show-members'),
          value: value,
          label: label,
          icon: Iconsax.people,
          chart: _buildLineChart(),
        );
      },
      loading: () => const _StatCardLoading(),
      error: (e, s) => _StatCardError(label: 'Members'),
    );
  }
}

class ServantsStatCard extends ConsumerWidget {
  const ServantsStatCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return statsAsync.when(
      data: (stats) {
        String value = '0';
        String label = 'Servants';

        if (stats is SuperAdminDashboardStats) {
          value = stats.totals.totalServants.toString();
          label = 'Total Servants';
        } else if (stats is PastorDashboardStats) {
          value = stats.totals.totalServants.toString();
          label = 'Your Servants';
        }

        return _StatCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFf5a623), Color(0xFFf76b1c)],
          ),
          onTap: () => context.go('/report-servants'),
          value: value,
          label: label,
          icon: Iconsax.lifebuoy,
          chart: _buildBarChart(double.tryParse(value) ?? 0),
        );
      },
      loading: () => const _StatCardLoading(),
      error: (e, s) => _StatCardError(label: 'Servants'),
    );
  }
}

class DepartmentsStatCard extends ConsumerWidget {
  const DepartmentsStatCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

Widget _buildPieChart() {
  return SizedBox(
    width: 80,
    height: 80,
    child: PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 28,
        startDegreeOffset: -90,
        sections: [
          PieChartSectionData(
            color: Colors.white.withOpacity(0.9),
            value: 35,
            showTitle: false,
            radius: 12,
          ),
          PieChartSectionData(
            color: Colors.white.withOpacity(0.7),
            value: 25,
            showTitle: false,
            radius: 12,
          ),
          PieChartSectionData(
            color: Colors.white.withOpacity(0.5),
            value: 20,
            showTitle: false,
            radius: 12,
          ),
          PieChartSectionData(
            color: Colors.white.withOpacity(0.3),
            value: 20,
            showTitle: false,
            radius: 12,
          ),
        ],
      ),
    ),
  );
}

Widget _buildBarChart(double total) {
  return SizedBox(
    width: 90,
    height: 50,
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (total * 1.5).clamp(10, double.infinity),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: total * 0.8,
                color: Colors.white.withOpacity(0.9),
                width: 10,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: total * 0.6,
                color: Colors.white.withOpacity(0.7),
                width: 10,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: total * 0.9,
                color: Colors.white.withOpacity(0.8),
                width: 10,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildLineChart() {
  return SizedBox(
    width: 100,
    height: 60,
    child: LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 1.5),
              FlSpot(2.5, 4),
              FlSpot(4, 2.8),
              FlSpot(5, 3.5),
            ],
            isCurved: true,
            curveSmoothness: 0.4,
            color: Colors.white,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.white.withOpacity(0.5),
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatefulWidget {
  final Gradient gradient;
  final VoidCallback onTap;
  final String value;
  final String? subtitle;
  final String label;
  final Widget chart;
  final IconData icon;

  const _StatCard({
    required this.gradient,
    required this.onTap,
    required this.value,
    this.subtitle,
    required this.label,
    required this.chart,
    required this.icon,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 170, // Increased height slightly to prevent overflow
      child: MouseRegion(
        onEnter: (_) {
          _hoverController.forward();
        },
        onExit: (_) {
          _hoverController.reverse();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _pulseController]),
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_hoverController.value * 0.02),
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.1 + (_hoverController.value * 0.1),
                      ),
                      blurRadius: 20 + (_hoverController.value * 10),
                      offset: Offset(0, 8 + (_hoverController.value * 4)),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        widget.icon,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.label,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Flexible(
                                  child: Text(
                                    widget.value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32, // Adjusted font size
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      widget.subtitle!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: widget.chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCardLoading extends StatelessWidget {
  const _StatCardLoading();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Shimmer.fromColors(
      baseColor: appColors.shimmerBase,
      highlightColor: appColors.shimmerHighlight,
      child: Container(
        height: 170, // Matched height
        width: 350,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appColors.scaffold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: appColors.scaffold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 32,
                    width: 70,
                    decoration: BoxDecoration(
                      color: appColors.scaffold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: appColors.scaffold,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardError extends StatelessWidget {
  final String label;
  const _StatCardError({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170, // Matched height
      width: 350,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load\n$label data',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}