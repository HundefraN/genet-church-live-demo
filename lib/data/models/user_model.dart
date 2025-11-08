enum UserRole {
  SUPER_ADMIN,
  PASTOR,
  SERVANT,
}

UserRole mapRoleFromString(String? roleString) {
  switch (roleString?.toUpperCase()) {
    case 'SUPER_ADMIN':
      return UserRole.SUPER_ADMIN;
    case 'PASTOR':
      return UserRole.PASTOR;
    case 'SERVANT':
      return UserRole.SERVANT;
    default:
      return UserRole.SERVANT;
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? churchId;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.churchId,
  });

  UserRole get roleEnum => mapRoleFromString(role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? assignedChurchId;
    if (json['Pastor'] != null && json['Pastor']['churchId'] != null) {
      assignedChurchId = json['Pastor']['churchId'];
    } else if (json['Servant'] != null && json['Servant']['churchId'] != null) {
      assignedChurchId = json['Servant']['churchId'];
    }

    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      churchId: assignedChurchId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'churchId': churchId,
    };
  }
}