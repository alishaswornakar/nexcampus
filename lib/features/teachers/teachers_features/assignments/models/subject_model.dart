class SubjectModel {
  final String id;
  final String subject;
  final String department;
  final String semester;

  SubjectModel({
    required this.id,
    required this.subject,
    required this.department,
    required this.semester,
  });

  factory SubjectModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return SubjectModel(
      id: id,
      subject: map["subject"] ?? "",
      department: map["department"] ?? "",
      semester: map["semester"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "subject": subject,
      "department": department,
      "semester": semester,
    };
  }
}