class AttendanceStudentModel {
  final String uid;
  final String fullName;
  final String roll;
  final String photoUrl;
  bool isPresent;

  AttendanceStudentModel({
    required this.uid,
    required this.fullName,
    required this.roll,
    required this.photoUrl,
    this.isPresent = true,
  });

  factory AttendanceStudentModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AttendanceStudentModel(
      uid: map["uid"] ?? "",
      fullName: map["fullName"] ?? "",
      roll: map["roll"] ?? "",
      photoUrl: map["photoUrl"] ?? "",
      isPresent: map["isPresent"] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "roll": roll,
      "photoUrl": photoUrl,
      "isPresent": isPresent,
    };
  }
}