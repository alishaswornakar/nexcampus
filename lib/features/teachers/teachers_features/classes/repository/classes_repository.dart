import '../models/student_model.dart';
import '../services/classes_service.dart';

class ClassesRepository {
  final ClassesService service;

  ClassesRepository(this.service);

  Stream<List<StudentModel>> students(
    String department,
    int? semester,
  ) {
    return service.studentsBySemester(
      department: department,
      semester: semester,
    );
  }

  Future<int> totalStudents(
    String department,
  ) {
    return service.totalStudents(department);
  }
}