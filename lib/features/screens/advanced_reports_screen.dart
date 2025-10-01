import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/shared_widgets/export_report_dialog.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:ui' as ui;
import 'dart:math';

class AdvancedReportsScreen extends ConsumerWidget {
  const AdvancedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 650;

    return statsAsync.when(
      data: (stats) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontSize: isSmallScreen ? 24 : 32,
                  ),
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
            LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth < 650
                  ? 2
                  : (constraints.maxWidth < 1200 ? 4 : 4);
              double childAspectRatio = constraints.maxWidth < 650 ? 1.0 : 1.25;

              final statCards = [
                _ReportStatCard(
                  icon: Iconsax.people,
                  value: stats.totalMembers.toString(),
                  label: 'Total Members',
                  color: theme.colorScheme.primary,
                ),
                _ReportStatCard(
                  icon: Iconsax.building,
                  value: stats.totalChurches.toString(),
                  label: 'Total Churches',
                  color: theme.colorScheme.secondary,
                ),
                _ReportStatCard(
                  icon: Iconsax.user_octagon,
                  value: stats.totalPastors.toString(),
                  label: 'Total Pastors',
                  color: const Color(0xFFF5A623),
                ),
                _ReportStatCard(
                  icon: Iconsax.lifebuoy,
                  value: stats.totalServants.toString(),
                  label: 'Total Servants',
                  color: theme.colorScheme.error,
                ),
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isSmallScreen ? 16 : 24,
                  mainAxisSpacing: isSmallScreen ? 16 : 24,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: statCards.length,
                itemBuilder: (context, index) => statCards[index],
              );
            }),
            const SizedBox(height: 24),
            _ResponsiveChartLayout(
              genderData: stats.membersByGender,
              statusData: stats.membersByStatus,
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutQuint),
      ),
      loading: () => Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      error: (e, s) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.warning_2,
                color: theme.colorScheme.onErrorContainer,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load analytics data',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveChartLayout extends StatelessWidget {
  final Map<String, int> genderData;
  final Map<String, int> statusData;

  const _ResponsiveChartLayout({
    required this.genderData,
    required this.statusData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 950) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: GenderDistributionCard(genderData: genderData),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: MemberStatusCard(statusData: statusData),
              ),
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
    final appColors = Theme.of(context).extension<AppColors>()!;
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 200;
      return Container(
        padding: EdgeInsets.all(isSmall ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appColors.surface,
              appColors.surface.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(isSmall ? 16 : 24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
            BoxShadow(
              color: appColors.shadow.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmall ? 8 : 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
                  ),
                  child: Icon(icon, color: color, size: isSmall ? 20 : 24),
                ),
                Container(
                  height: isSmall ? 30 : 40,
                  width: 3,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: isSmall ? 14 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    fontSize: isSmall ? 28 : null,
                  ),
                ),
              ],
            ),
            if (!isSmall) const Spacer(),
            if (isSmall) const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: isSmall ? 4 : 6,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fade(duration: 400.ms)
          .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuint);
    });
  }
}

class GenderDistributionCard extends StatelessWidget {
  final Map<String, int> genderData;
  const GenderDistributionCard({super.key, required this.genderData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final maleCount = genderData['MALE'] ?? 0;
    final femaleCount = genderData['FEMALE'] ?? 0;
    final total = maleCount + femaleCount;
    final malePercentage = total > 0 ? (maleCount / total * 100).round() : 0;
    final femalePercentage = total > 0 ? (femaleCount / total * 100).round() : 0;

    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 450;
      final barWidth = isSmall ? 40.0 : 60.0;
      final chartHeight = isSmall ? 240.0 : 260.0;
      final maxCount = (maleCount > femaleCount ? maleCount : femaleCount) * 1.2;

      return Container(
        padding: EdgeInsets.all(isSmall ? 20 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appColors.surface,
              appColors.surface.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
            BoxShadow(
              color: appColors.shadow.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Member Gender Distribution',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    fontSize: isSmall ? 18 : null,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.people,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total: $total',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmall ? 12 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: chartHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCount,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: maleCount.toDouble(),
                          width: barWidth,
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxCount,
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: femaleCount.toDouble(),
                          width: barWidth,
                          color: theme.colorScheme.secondary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxCount,
                            color: theme.colorScheme.secondary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 110,
                        getTitlesWidget: (value, meta) {
                          final style = TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmall ? 12 : 14,
                            color: appColors.textPrimary,
                          );

                          Widget content;
                          switch (value.toInt()) {
                            case 0:
                              content = _GenderIndicator(
                                isSmall: isSmall,
                                theme: theme,
                                icon: Iconsax.man,
                                label: 'Male',
                                percentage: malePercentage,
                                color: theme.colorScheme.primary,
                              );
                              break;
                            case 1:
                              content = _GenderIndicator(
                                isSmall: isSmall,
                                theme: theme,
                                icon: Iconsax.woman,
                                label: 'Female',
                                percentage: femalePercentage,
                                color: theme.colorScheme.secondary,
                              );
                              break;
                            default:
                              content = const SizedBox();
                              break;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: content,
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(12),
                      tooltipMargin: 8,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${group.x == 0 ? 'Male' : 'Female'}: ${rod.toY.toInt()}',
                          TextStyle(
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuint,
          delay: 200.ms);
    });
  }
}

class _GenderIndicator extends StatelessWidget {
  const _GenderIndicator({
    required this.isSmall,
    required this.theme,
    required this.icon,
    required this.label,
    required this.percentage,
    required this.color,
  });

  final bool isSmall;
  final ThemeData theme;
  final IconData icon;
  final String label;
  final int percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: isSmall ? 40 : 48,
          height: isSmall ? 40 : 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: isSmall ? 20 : 24),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: isSmall ? 12 : 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        Text(
          '$percentage%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 11 : 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

class MemberStatusCard extends StatelessWidget {
  final Map<String, int> statusData;
  const MemberStatusCard({super.key, required this.statusData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      const Color(0xFFF5A623),
      theme.colorScheme.error,
      Colors.green,
      Colors.purple,
    ];
    final statusEntries =
    statusData.entries.where((entry) => entry.value > 0).toList();
    final totalMembers =
    statusEntries.fold(0, (sum, entry) => sum + entry.value);

    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 350;
      final chartSize = min(constraints.maxWidth * 0.6, isSmall ? 180.0 : 220.0);
      final radius = chartSize / 2;
      final centerSpaceRadius = radius * 0.6;

      return Container(
        padding: EdgeInsets.all(isSmall ? 20 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appColors.surface,
              appColors.surface.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
            BoxShadow(
              color: appColors.shadow.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Member Status',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    fontSize: isSmall ? 18 : null,
                  ),
                ),
                if (totalMembers > 0)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.chart,
                          color: theme.colorScheme.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Total: $totalMembers',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmall ? 12 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            if (totalMembers == 0)
              SizedBox(
                height: chartSize,
                child: Center(
                    child: Text('No data available.',
                        style: TextStyle(color: appColors.textSecondary))),
              )
            else
              SizedBox(
                height: chartSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: centerSpaceRadius,
                        sections: List.generate(statusEntries.length, (i) {
                          final entry = statusEntries[i];
                          final percentage =
                          (entry.value / totalMembers * 100).round();
                          return PieChartSectionData(
                            color: colors[i % colors.length],
                            value: entry.value.toDouble(),
                            title: '',
                            radius: (radius - centerSpaceRadius) * 0.9,
                          );
                        }),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalMembers',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: appColors.textPrimary,
                            fontSize: isSmall ? 28 : null,
                          ),
                        ),
                        Text(
                          'Members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: appColors.textSecondary,
                            fontSize: isSmall ? 10 : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (totalMembers > 0)
              Column(
                children: List.generate(statusEntries.length, (i) {
                  final entry = statusEntries[i];
                  final percentage =
                  (entry.value / totalMembers * 100).toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        _Indicator(
                            color: colors[i % colors.length],
                            text: entry.key,
                            isSmall: isSmall),
                        const Spacer(),
                        Text(
                          '${entry.value} ($percentage%)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors[i % colors.length],
                            fontSize: isSmall ? 12 : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ).animate().fade(duration: 500.ms, delay: 400.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuint,
          delay: 400.ms);
    });
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSmall;

  const _Indicator(
      {required this.color, required this.text, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    String formattedText = text.toLowerCase();
    formattedText =
        formattedText.substring(0, 1).toUpperCase() + formattedText.substring(1);

    return Row(
      children: <Widget>[
        Container(
          width: isSmall ? 14 : 18,
          height: isSmall ? 14 : 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          formattedText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: isSmall ? 13 : null,
          ),
        ),
      ],
    );
  }
}