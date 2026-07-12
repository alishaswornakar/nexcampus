class StudentModel {
  final String uid;
  final String fullName;
  final String email;
  final String department;
  final int? semester;
  final String roll;
  final String role;
  final String photoUrl;

  StudentModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.department,
    required this.semester,
    required this.roll,
    required this.role,
    required this.photoUrl,
  });

  factory StudentModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return StudentModel(
      uid: map['uid'] ?? documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester']?.toInt(), 
      roll: map['roll'] ?? '',
      role: map['role'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'department': department,
      'semester': semester,
      'roll': roll,
      'role': role,
      'photoUrl': photoUrl,
    };
  }
}