class PastorDashboardStats {
  final int totalMembers;
  final int totalServants;
  final Map<String, int> membersByStatus;

  PastorDashboardStats({
    required this.totalMembers,
    required this.totalServants,
    required this.membersByStatus,
  });

  factory PastorDashboardStats.fromJson(Map<String, dynamic> json) {
    return PastorDashboardStats(
      totalMembers: json['totalMembers'] as int? ?? 0,
      totalServants: json['totalServants'] as int? ?? 0,
      membersByStatus: Map<String, int>.from(json['membersByStatus'] ?? {}),
    );
  }
}