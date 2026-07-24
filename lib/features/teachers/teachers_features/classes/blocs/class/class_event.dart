

abstract class ClassesEvent {}

class LoadStudents extends ClassesEvent {
  final String department;
  final String? semester;

  LoadStudents({
    required this.department,
    this.semester,
  });
}