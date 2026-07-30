/// Minimal subject reference for the admin attendance filter.
///
/// Backed by the same `subjects` collection the teacher side reads
/// (see teacher-side `SubjectModel` / `AttendanceService.getSubjects`).
/// Only `id` and `name` are needed here since the admin filter just
/// needs to populate a dropdown and pass `subjectId` into the query.
class AdminSubjectModel {
  final String id;
  final String name;

  AdminSubjectModel({
    required this.id,
    required this.name,
  });

  factory AdminSubjectModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminSubjectModel(
      id: id,
      // The teacher-side subject doc stores the subject name under
      // the `subject` field (see SubjectModel usage: `subject.subject`).
      name: map['subject'] ?? map['name'] ?? 'Unknown Subject',
    );
  }
}
