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
}