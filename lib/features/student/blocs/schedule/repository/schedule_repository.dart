// lib/features/student/blocs/schedule/repository/schedule_repository.dart
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';
import '../services/schedule_service.dart';

/// Read-only counterpart of the teacher's ScheduleRepository. Same
/// thin pass-through shape, just without the write methods a student
/// never needs.
class ScheduleRepository {
  final ScheduleService service;

  ScheduleRepository(this.service);

  /// Student Schedule (by department + semester)
  Stream<List<ScheduleModel>> getStudentSchedule({
    required String department,
    required String semester,
  }) {
    return service.getStudentSchedule(
      department: department,
      semester: semester,
    );
  }

  /// Single Schedule
  Future<ScheduleModel?> getScheduleById(String scheduleId) {
    return service.getScheduleById(scheduleId);
  }
}
