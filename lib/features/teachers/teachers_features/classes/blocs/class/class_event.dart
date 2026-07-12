

abstract class ClassesEvent {}

class LoadStudents extends ClassesEvent {
  final String department;
  final int? semester;

  LoadStudents({
    required this.department,
    this.semester,
  });
}