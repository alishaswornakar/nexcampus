part of 'schedule_bloc.dart';

abstract class ScheduleEvent {}

/// Load schedules by Department + Semester
class LoadSchedulesEvent extends ScheduleEvent {
  final String department;
  final String semester;

  LoadSchedulesEvent({
    required this.department,
    required this.semester,
  });
}

/// Load Teacher Schedule
class LoadTeacherSchedulesEvent extends ScheduleEvent {
  final String teacherId;

  LoadTeacherSchedulesEvent({
    required this.teacherId,
  });
}

/// Load Student Schedule
class LoadStudentSchedulesEvent extends ScheduleEvent {
  final String department;
  final String semester;

  LoadStudentSchedulesEvent({
    required this.department,
    required this.semester,
  });
}

/// Add Schedule
class AddScheduleEvent extends ScheduleEvent {
  final ScheduleModel schedule;

  AddScheduleEvent(this.schedule);
}

/// Update Schedule
class UpdateScheduleEvent extends ScheduleEvent {
  final ScheduleModel schedule;

  UpdateScheduleEvent(this.schedule);
}

/// Delete Schedule
class DeleteScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  DeleteScheduleEvent(this.scheduleId);
}