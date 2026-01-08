import 'dashboard_base_model.dart';

class SuperAdminDashboardStats extends DashboardStatsBase {
  @override
  final String timeframe;
  @override
  final DashboardTotals? totals;
  @override
  final DashboardNewInTimeframe? newInTimeframe;
  @override
  final DashboardDistributions? distributions;

  SuperAdminDashboardStats({
    required this.timeframe,
    this.totals,
    this.newInTimeframe,
    this.distributions,
  });

  factory SuperAdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardStats(
      timeframe: json['timeframe'] as String? ?? 'all',
      totals: json['totals'] != null
          ? DashboardTotals.fromJson(json['totals'])
          : null,
      newInTimeframe: json['newInTimeframe'] != null
          ? DashboardNewInTimeframe.fromJson(json['newInTimeframe'])
          : null,
      distributions: json['distributions'] != null
          ? DashboardDistributions.fromJson(json['distributions'])
          : null,
    );
  }
}
