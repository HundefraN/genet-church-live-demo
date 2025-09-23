
class Member {
  final String id;
  String firstName;
  String fatherName;
  String phone;
  String address;
  String churchBranch;

  Member({
    required this.id,
    required this.firstName,
    required this.fatherName,
    required this.phone,
    required this.address,
    required this.churchBranch,
  });

  String get fullName => '$firstName $fatherName';

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,

      firstName: json['firstName'] as String,
      fatherName: json['fatherName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      churchBranch: json['churchBranch'] as String,
    );
  }

  // Convert a Member object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'fatherName': fatherName,
      'phone': phone,
      'address': address,
      'churchBranch': churchBranch,
    };
  }
}