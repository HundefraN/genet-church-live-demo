import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/shared_widgets/export_report_dialog.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';

class AdvancedReportsScreen extends ConsumerWidget {
  const AdvancedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) => ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Dashboard',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              PrimaryButton(
                text: 'Export Report',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ExportReportDialog(),
                  );
                },
                icon: Iconsax.document_download,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _ReportStatCard(
                icon: Iconsax.people,
                value: stats.totalMembers.toString(),
                label: 'Total Members',
                color: AppTheme.primaryBlue,
              ),
              _ReportStatCard(
                icon: Iconsax.building,
                value: stats.totalChurches.toString(),
                label: 'Total Churches',
                color: AppTheme.accentTeal,
              ),
              _ReportStatCard(
                icon: Iconsax.user_octagon,
                value: stats.totalPastors.toString(),
                label: 'Total Pastors',
                color: AppTheme.accentOrange,
              ),
              _ReportStatCard(
                icon: Iconsax.lifebuoy,
                value: stats.totalServants.toString(),
                label: 'Total Servants',
                color: AppTheme.destructiveRed,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ResponsiveChartLayout(
            genderData: stats.membersByGender,
            statusData: stats.membersByStatus,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Failed to load analytics data: $e')),
    );
  }
}

class _ResponsiveChartLayout extends StatelessWidget {
  final Map<String, int> genderData;
  final Map<String, int> statusData;

  const _ResponsiveChartLayout(
      {required this.genderData, required this.statusData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: GenderDistributionCard(genderData: genderData)),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: MemberStatusCard(statusData: statusData)),
            ],
          );
        } else {
          return Column(
            children: [
              GenderDistributionCard(genderData: genderData),
              const SizedBox(height: 24),
              MemberStatusCard(statusData: statusData),
            ],
          );
        }
      },
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ReportStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GenderDistributionCard extends StatelessWidget {
  final Map<String, int> genderData;
  const GenderDistributionCard({super.key, required this.genderData});

  @override
  Widget build(BuildContext context) {
    final maleCount = genderData['MALE'] ?? 0;
    final femaleCount = genderData['FEMALE'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Member Gender Distribution',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          SizedBox(
            height: 230,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: maleCount.toDouble(),
                        width: 40,
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(4))
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: femaleCount.toDouble(),
                        width: 40,
                        color: AppTheme.accentTeal,
                        borderRadius: BorderRadius.circular(4))
                  ]),
                ],
                titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14);
                            Widget text;
                            switch (value.toInt()) {
                              case 0:
                                text = const Text('Male', style: style);
                                break;
                              case 1:
                                text = const Text('Female', style: style);
                                break;
                              default:
                                text = const Text('', style: style);
                                break;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: text,
                            );
                          },
                        ))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MemberStatusCard extends StatelessWidget {
  final Map<String, int> statusData;
  const MemberStatusCard({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.accentTeal,
      AppTheme.accentOrange,
      AppTheme.destructiveRed,
      Colors.grey
    ];
    final statusEntries =
    statusData.entries.where((entry) => entry.value > 0).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Member Status',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: List.generate(statusEntries.length, (i) {
                  final entry = statusEntries[i];
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    radius: 50,
                    titleStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(statusEntries.length, (i) {
            final entry = statusEntries[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _Indicator(
                  color: colors[i % colors.length],
                  text: entry.key.toLowerCase()),
            );
          })
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const _Indicator({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium)
      ],
    );
  }
}