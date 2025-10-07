
import '../../state/lib/data/models/dashboard_base_model.dart';

class PastorDashboardStats extends DashboardStatsBase {
  final int totalMembers;
  final int totalServants;
  final Map<String, int> membersByStatus;
  final Map<String, int> membersByGender;
  final Map<String, int> membersByBaptismStatus;

  PastorDashboardStats({
    required this.totalMembers,
    required this.totalServants,
    required this.membersByStatus,
    required this.membersByGender,
    required this.membersByBaptismStatus,
  });

  factory PastorDashboardStats.fromJson(Map<String, dynamic> json) {
    return PastorDashboardStats(
      totalMembers: json['totalMembers'] as int? ?? 0,
      totalServants: json['totalServants'] as int? ?? 0,
      membersByStatus: Map<String, int>.from(json['membersByStatus'] ?? {}),
      membersByGender: Map<String, int>.from(json['membersByGender'] ?? {}),
      membersByBaptismStatus: Map<String, int>.from(json['membersByBaptismStatus'] ?? {}),
    );
  }
}