class Church {
  final String id;
  String name;
  String phoneNumber;
  String officeNumber;
  String email;
  String locationName;
  List<String> pastorIds;

  Church({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.officeNumber,
    required this.email,
    required this.locationName,
    required this.pastorIds,
  });
}