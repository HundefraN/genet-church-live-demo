class PastorUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final String createdAt;

  PastorUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory PastorUser.fromJson(Map<String, dynamic> json) {
    return PastorUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'N/A',
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class Pastor {
  final String id;
  final String userId;
  final String? churchId;
  final PastorUser user;

  Pastor({
    required this.id,
    required this.userId,
    this.churchId,
    required this.user,
  });

  factory Pastor.fromJson(Map<String, dynamic> json) {
    return Pastor(
      id: json['id'] as String,
      userId: json['userId'] as String,
      churchId: json['churchId'] as String?,
      user: PastorUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  static Map<String, dynamic> creationToJson({
    required String fullName,
    required String email,
    required String password,
  }) {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }
}