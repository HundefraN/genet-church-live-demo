
import 'dashboard_base_model.dart';

class SuperAdminDashboardStats extends DashboardStatsBase {
  final int totalChurches;
  final int totalPastors;
  final int totalServants;
  final int totalMembers;
  final Map<String, int> membersByGender;
  final Map<String, int> membersByStatus;
  final Map<String, int> membersByBaptismStatus;

  SuperAdminDashboardStats({
    required this.totalChurches,
    required this.totalPastors,
    required this.totalServants,
    required this.totalMembers,
    required this.membersByGender,
    required this.membersByStatus,
    required this.membersByBaptismStatus,
  });

  factory SuperAdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return SuperAdminDashboardStats(
      totalChurches: json['totalChurches'] as int? ?? 0,
      totalPastors: json['totalPastors'] as int? ?? 0,
      totalServants: json['totalServants'] as int? ?? 0,
      totalMembers: json['totalMembers'] as int? ?? 0,
      membersByGender: Map<String, int>.from(json['membersByGender'] ?? {}),
      membersByStatus: Map<String, int>.from(json['membersByStatus'] ?? {}),
      membersByBaptismStatus: Map<String, int>.from(json['membersByBaptismStatus'] ?? {}),
    );
  }
}