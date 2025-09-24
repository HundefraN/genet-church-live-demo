class Department {
  final String id;
  final String name;
  final String churchId;

  Department({
    required this.id,
    required this.name,
    required this.churchId,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      churchId: json['churchId'],
    );
  }
}