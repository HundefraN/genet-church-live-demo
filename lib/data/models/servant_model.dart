class Servant {
  final String id;
  final String userId;
  final String churchId;
  final String? departmentId;

  Servant({
    required this.id,
    required this.userId,
    required this.churchId,
    this.departmentId,
  });

  factory Servant.fromJson(Map<String, dynamic> json) {
    return Servant(
      id: json['id'],
      userId: json['userId'],
      churchId: json['churchId'],
      departmentId: json['departmentId'],
    );
  }
}