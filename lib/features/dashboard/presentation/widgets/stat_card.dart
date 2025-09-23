import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:go_router/go_router.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';

class IncomeStatCard extends StatelessWidget {
  const IncomeStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryBlue,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Navigating to detailed financial reports... (Feature coming soon)'),
              backgroundColor: AppTheme.primaryBlue,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'ETB 20k',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monthly Tithe',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

class VolunteersStatCard extends ConsumerWidget {
  const VolunteersStatCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastorsCount = ref.watch(pastorsProvider).length;

    return Material(
      color: const Color(0xFF16D0A7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go('/report-pastors'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pastorsCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pastors & Volunteers',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10,
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: [
                      _makeBar(0, 9),
                      _makeBar(1, 6),
                      _makeBar(2, 4),
                      _makeBar(3, 6),
                      _makeBar(4, 3),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.white,
          width: 8,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
      ],
    );
  }
}

class MembersStatCard extends ConsumerWidget {
  const MembersStatCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Since membersProvider is removed, we'll show a static number for now.
    const membersCount = 0;

    return Material(
      color: const Color(0xFFFEC53D),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go('/show-members'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      membersCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Active Members',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(
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
                          FlSpot(1, 3.5),
                          FlSpot(2.5, 0.5),
                          FlSpot(4, 2),
                          FlSpot(5, 1.8),
                        ],
                        isCurved: false,
                        color: Colors.white,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}