
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

  Map<String, dynamic> toJson() => {
    'city': city,
    'subCity': subCity,
    'woreda': woreda,
    'placeName': placeName,
  };
}

class Member {
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