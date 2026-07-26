import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';

import '../services/schedule_service.dart';

class ScheduleRepository {
  final ScheduleService service;

  ScheduleRepository(this.service);

  /// Create Schedule
  Future<void> createSchedule({
    required ScheduleModel schedule,
  }) {
    return service.createSchedule(
      schedule: schedule,
    );
  }

  /// Update Schedule
  Future<void> updateSchedule({
    required ScheduleModel schedule,
  }) {
    return service.updateSchedule(
      schedule: schedule,
    );
  }

  /// Delete Schedule
  Future<void> deleteSchedule(
    String scheduleId,
  ) {
    return service.deleteSchedule(
      scheduleId,
    );
  }

  /// Teacher Schedule
  Stream<List<ScheduleModel>> getTeacherSchedule({
    required String teacherId,
  }) {
    return service.getTeacherSchedule(
      teacherId: teacherId,
    );
  }

  /// Student Schedule
  Stream<List<ScheduleModel>> getStudentSchedule({
    required String department,
    required String semester,
  }) {
    return service.getStudentSchedule(
      department: department,
      semester: semester,
    );
  }

  /// Department + Semester Schedule
  Stream<List<ScheduleModel>> getSchedule({
    required String department,
    required String semester,
  }) {
    return service.getSchedule(
      department: department,
      semester: semester,
    );
  }

  /// Single Schedule
  Future<ScheduleModel?> getScheduleById(
    String scheduleId,
  ) {
    return service.getScheduleById(
      scheduleId,
    );
  }
}