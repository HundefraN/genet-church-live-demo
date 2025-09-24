import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';

class ChurchesStatCard extends ConsumerWidget {
  const ChurchesStatCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    return statsAsync.when(
      data: (stats) => _StatCard(
        color: AppTheme.primaryBlue,
        onTap: () => context.go('/report-churchs'),
        value: stats.totalChurches.toString(),
        label: 'Total Churches',
        chart: SizedBox(
          width: 70,
          height: 70,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 25,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                    color: const Color(0xFFFF6B6B),
                    value: 35,
                    showTitle: false,
                    radius: 10),
                PieChartSectionData(
                    color: const Color(0xFF4ECDC4),
                    value: 25,
                    showTitle: false,
                    radius: 10),
                PieChartSectionData(
                    color: const Color(0xFF45B7D1),
                    value: 20,
                    showTitle: false,
                    radius: 10),
                PieChartSectionData(
                    color: const Color(0xFFF7DC6F),
                    value: 20,
                    showTitle: false,
                    radius: 10),
              ],
            ),
          ),
        ),
      ),
      loading: () => const _StatCardLoading(color: AppTheme.primaryBlue),
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
      data: (stats) => _StatCard(
        color: const Color(0xFF16D0A7),
        onTap: () => context.go('/report-pastors'),
        value: stats.totalPastors.toString(),
        label: 'Total Pastors',
        chart: SizedBox(
          width: 80,
          height: 40,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (stats.totalPastors * 1.5).clamp(10, double.infinity).toDouble(),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(
                      toY: (stats.totalPastors * 0.8).toDouble(),
                      color: Colors.white,
                      width: 8,
                      borderRadius: const BorderRadius.all(Radius.circular(2)))
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(
                      toY: (stats.totalPastors * 0.5).toDouble(),
                      color: Colors.white,
                      width: 8,
                      borderRadius: const BorderRadius.all(Radius.circular(2)))
                ]),
              ],
            ),
          ),
        ),
      ),
      loading: () => const _StatCardLoading(color: Color(0xFF16D0A7)),
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
      data: (stats) => _StatCard(
        color: const Color(0xFFFEC53D),
        onTap: () => context.go('/show-members'),
        value: stats.totalMembers.toString(),
        label: 'Active Members',
        chart: SizedBox(
          width: 90,
          height: 50,
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
                    FlSpot(2.5, 2.5),
                    FlSpot(4, 2),
                    FlSpot(5, 1.8),
                  ],
                  isCurved: true,
                  color: Colors.white,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const _StatCardLoading(color: Color(0xFFFEC53D)),
      error: (e, s) => _StatCardError(label: 'Members'),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final String value;
  final String label;
  final Widget chart;

  const _StatCard(
      {required this.color,
        required this.onTap,
        required this.value,
        required this.label,
        required this.chart});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(label,
                        style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              chart,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardLoading extends StatelessWidget {
  final Color color;
  const _StatCardLoading({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
    );
  }
}

class _StatCardError extends StatelessWidget {
  final String label;
  const _StatCardError({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12)),
      child: Center(
          child: Text('Could not load\n$label data',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700))),
    );
  }
}