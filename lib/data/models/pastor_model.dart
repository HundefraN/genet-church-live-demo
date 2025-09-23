
// A simple model for the nested user object
class PastorUser {
  final String id;
  final String fullName;
  final String email;

  PastorUser({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory PastorUser.fromJson(Map<String, dynamic> json) {
    return PastorUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }
}

class Pastor {
  final String id;
  final String userId;
  final String? churchId;
  final PastorUser user; // Add this user object

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

  // toJson for creating a pastor is different
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