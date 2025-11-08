T? _enumFromString<T>(List<T> values, String? value) {
  if (value == null) return null;
  try {
    return values.firstWhere((v) => v.toString().split('.').last == value);
  } catch (e) {
    return null;
  }
}

enum Gender { MALE, FEMALE }
enum BaptismStatus { BAPTIZED, NOT_BAPTIZED, PENDING }
enum EducationLevel { NONE, PRIMARY, SECONDARY, DIPLOMA, DEGREE, MASTERS, PHD }
enum JobStatus { EMPLOYED, UNEMPLOYED, STUDENT, OTHER }
enum MarriageStatus { SINGLE, MARRIED, DIVORCED, WIDOWED }
enum IncomeRange { LOW, MEDIUM, HIGH }
enum MemberStatus { ACTIVE, INACTIVE, TRANSFERRED, DEAD, UNKNOWN }

class Address {
  final String city;
  final String subCity;
  final String woreda;
  final String placeName;

  Address({
    required this.city,
    required this.subCity,
    required this.woreda,
    required this.placeName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] as String? ?? '',
      subCity: json['subCity'] as String? ?? '',
      woreda: json['woreda'] as String? ?? '',
      placeName: json['placeName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'city': city,
    'subCity': subCity,
    'woreda': woreda,
    'placeName': placeName,
  };
}

class Member {
  final String? id;
  final String fullName;
  final String birthDate;
  final String birthPlace;
  final String motherTongue;
  final Gender gender;
  final String phoneNumber;
  final BaptismStatus baptismStatus;
  final EducationLevel educationLevel;
  final JobStatus jobStatus;
  final MarriageStatus marriageStatus;
  final IncomeRange incomeRange;
  final MemberStatus memberStatus;
  final Address address;
  final String? photoUrl;
  final String? bornAgainDate;
  final String? previousChurch;
  final String? reasonForTransfer;
  final String? fieldOfStudy;
  final String? workLocation;

  Member({
    this.id,
    required this.fullName,
    required this.birthDate,
    required this.birthPlace,
    required this.motherTongue,
    required this.gender,
    required this.phoneNumber,
    required this.baptismStatus,
    required this.educationLevel,
    required this.jobStatus,
    required this.marriageStatus,
    required this.incomeRange,
    required this.memberStatus,
    required this.address,
    this.photoUrl,
    this.bornAgainDate,
    this.previousChurch,
    this.reasonForTransfer,
    this.fieldOfStudy,
    this.workLocation,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String?,
      fullName: json['fullName'] as String,
      photoUrl: json['photoUrl'] as String?,
      birthDate: json['birthDate'] as String,
      birthPlace: json['birthPlace'] as String,
      motherTongue: json['motherTongue'] as String,
      gender: _enumFromString(Gender.values, json['gender']) ?? Gender.MALE,
      phoneNumber: json['phoneNumber'] as String,
      bornAgainDate: json['bornAgainDate'] as String?,
      baptismStatus: _enumFromString(BaptismStatus.values, json['baptismStatus']) ?? BaptismStatus.PENDING,
      previousChurch: json['previousChurch'] as String?,
      reasonForTransfer: json['reasonForTransfer'] as String?,
      educationLevel: _enumFromString(EducationLevel.values, json['educationLevel']) ?? EducationLevel.NONE,
      fieldOfStudy: json['fieldOfStudy'] as String?,
      jobStatus: _enumFromString(JobStatus.values, json['jobStatus']) ?? JobStatus.OTHER,
      workLocation: json['workLocation'] as String?,
      marriageStatus: _enumFromString(MarriageStatus.values, json['marriageStatus']) ?? MarriageStatus.SINGLE,
      incomeRange: _enumFromString(IncomeRange.values, json['incomeRange']) ?? IncomeRange.LOW,
      memberStatus: _enumFromString(MemberStatus.values, json['memberStatus']) ?? MemberStatus.UNKNOWN,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'photoUrl': photoUrl,
    'birthDate': birthDate,
    'birthPlace': birthPlace,
    'motherTongue': motherTongue,
    'gender': gender.name,
    'phoneNumber': phoneNumber,
    'bornAgainDate': bornAgainDate,
    'baptismStatus': baptismStatus.name,
    'previousChurch': previousChurch,
    'reasonForTransfer': reasonForTransfer,
    'educationLevel': educationLevel.name,
    'fieldOfStudy': fieldOfStudy,
    'jobStatus': jobStatus.name,
    'workLocation': workLocation,
    'marriageStatus': marriageStatus.name,
    'incomeRange': incomeRange.name,
    'memberStatus': memberStatus.name,
    'address': address.toJson(),
  };
}