import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/subject_services.dart';

import '../models/subject_model.dart';


class SubjectRepository {
  final SubjectService service;

  SubjectRepository(this.service);

  Stream<List<SubjectModel>> getSubjects({
    required String department,
    required String semester,
  }) {
    return service.getSubjects(
      department: department,
      semester: semester,
    );
  }
}