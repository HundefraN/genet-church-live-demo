// lib/data/models/church_model.dart

class Church {
  final String id;
  String name;
  String? locationLink;
  String? establishmentDate;
  String? dateCreated; // Add this field
  String? headOfficeId;

  Church({
    required this.id,
    required this.name,
    this.locationLink,
    this.establishmentDate,
    this.dateCreated, // Add to constructor
    this.headOfficeId,
  });

  factory Church.fromJson(Map<String, dynamic> json) {
    return Church(
      id: json['id'] as String,
      name: json['name'] as String,
      locationLink: json['locationLink'] as String?,
      establishmentDate: json['establishmentDate'] as String?,
      dateCreated: json['dateCreated'] as String?, // Parse from JSON
      headOfficeId: json['headOfficeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'locationLink': locationLink,
      'establishmentDate': establishmentDate,
      'Head_office': headOfficeId,
    };
  }
}