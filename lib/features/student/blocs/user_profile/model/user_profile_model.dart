class UserProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? photoUrl;
  final String? studentId;
  final String? department;
  final String? semester;
  final String? section;
  final String? rollNumber;
  final String? bloodGroup;
  final DateTime? dateOfBirth;
  final String? guardianName;
  final String? guardianPhone;
  final DateTime? joinedDate;

  const UserProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.photoUrl,
    this.studentId,
    this.department,
    this.semester,
    this.section,
    this.rollNumber,
    this.bloodGroup,
    this.dateOfBirth,
    this.guardianName,
    this.guardianPhone,
    this.joinedDate,
  });

  factory UserProfileModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfileModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      photoUrl: map['photoUrl'],
      studentId: map['studentId'],
      department: map['department'],
      semester: map['semester'],
      section: map['section'],
      rollNumber: map['rollNumber'],
      bloodGroup: map['bloodGroup'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'])
          : null,
      guardianName: map['guardianName'],
      guardianPhone: map['guardianPhone'],
      joinedDate: map['joinedDate'] != null
          ? DateTime.tryParse(map['joinedDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'photoUrl': photoUrl,
      'studentId': studentId,
      'department': department,
      'semester': semester,
      'section': section,
      'rollNumber': rollNumber,
      'bloodGroup': bloodGroup,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'joinedDate': joinedDate?.toIso8601String(),
    };
  }

  UserProfileModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? photoUrl,
    String? studentId,
    String? department,
    String? semester,
    String? section,
    String? rollNumber,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? guardianName,
    String? guardianPhone,
    DateTime? joinedDate,
  }) {
    return UserProfileModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}
