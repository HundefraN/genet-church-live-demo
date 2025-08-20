import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';

class AdvancedReportsScreen extends StatelessWidget {
  const AdvancedReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
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
              onPressed: () {},
              icon: Iconsax.document_download,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: const [
            _ReportStatCard(
              icon: Iconsax.people,
              value: '1,284',
              label: 'Total Members',
              color: AppTheme.primaryBlue,
            ),
            _ReportStatCard(
              icon: Iconsax.user_add,
              value: '+32',
              label: 'New Members (30d)',
              color: AppTheme.accentTeal,
            ),
            _ReportStatCard(
              icon: Iconsax.task_square,
              value: '78%',
              label: 'Average Attendance',
              color: AppTheme.accentOrange,
            ),
            _ReportStatCard(
              icon: Iconsax.wallet_3,
              value: 'ETB 1.2M',
              label: 'Giving (YTD)',
              color: AppTheme.destructiveRed,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ResponsiveChartLayout(),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ResponsiveChartLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double breakpoint = 900.0;

        if (constraints.maxWidth > breakpoint) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: GrowthTrendCard()),
              SizedBox(width: 24),
              Expanded(flex: 1, child: DemographicsCard()),
            ],
          );
        } else {
          return const Column(
            children: [
              GrowthTrendCard(),
              SizedBox(height: 24),
              DemographicsCard(),
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

class DemographicsCard extends StatelessWidget {
  const DemographicsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member Demographics',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(color: AppTheme.primaryBlue, value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: AppTheme.accentTeal, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: AppTheme.accentOrange, value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: AppTheme.destructiveRed, value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _Indicator(color: AppTheme.primaryBlue, text: 'Adults (25-55)'),
          const SizedBox(height: 8),
          const _Indicator(color: AppTheme.accentTeal, text: 'Young Adults (18-24)'),
          const SizedBox(height: 8),
          const _Indicator(color: AppTheme.accentOrange, text: 'Youth (<18)'),
          const SizedBox(height: 8),
          const _Indicator(color: AppTheme.destructiveRed, text: 'Seniors (55+)'),
        ],
      ),
    );
  }
}

class GrowthTrendCard extends StatelessWidget {
  const GrowthTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membership Growth Trend (6 Months)',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), FlSpot(4, 4), FlSpot(5, 6)],
                    isCurved: true,
                    color: AppTheme.accentTeal,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: AppTheme.accentTeal.withOpacity(0.2)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 1), FlSpot(1, 1), FlSpot(2, 1.5), FlSpot(3, 1), FlSpot(4, 2), FlSpot(5, 1)],
                    isCurved: true,
                    color: AppTheme.destructiveRed,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: AppTheme.destructiveRed.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
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