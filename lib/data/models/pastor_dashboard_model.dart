import 'dashboard_base_model.dart';
import 'dashboard_model.dart';

class PastorDashboardStats extends DashboardStatsBase {
  final String timeframe;
  final DashboardTotals totals;
  final DashboardNewInTimeframe newInTimeframe;
  final DashboardDistributions distributions;

  PastorDashboardStats({
    required this.timeframe,
    required this.totals,
    required this.newInTimeframe,
    required this.distributions,
  });

  factory PastorDashboardStats.fromJson(Map<String, dynamic> json) {
    return PastorDashboardStats(
      timeframe: json['timeframe'] as String? ?? 'all',
      // FIX: Map directly from root JSON to support flat structure
      totals: DashboardTotals.fromJson(json),
      newInTimeframe: DashboardNewInTimeframe.fromJson(json),
      distributions: DashboardDistributions.fromJson(json),
    );
  }
}