class Church {
  final String id;
  String name;
  String? locationLink;
  String? establishmentDate;
  String? headOfficeId;

  Church({
    required this.id,
    required this.name,
    this.locationLink,
    this.establishmentDate,
    this.headOfficeId,
  });

  factory Church.fromJson(Map<String, dynamic> json) {
    return Church(
      id: json['id'] as String,
      name: json['name'] as String,
      locationLink: json['locationLink'] as String?,
      establishmentDate: json['establishmentDate'] as String?,
      headOfficeId: json['headOfficeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'locationLink': locationLink,
      'establishmentDate': establishmentDate,
      'Head_office': headOfficeId, // Note the backend uses 'Head_office' for creation
    };
  }
}