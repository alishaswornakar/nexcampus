part of 'schedule_bloc.dart';

abstract class ScheduleEvent {}

/// Load Student Schedule (by department + semester)
class LoadStudentSchedulesEvent extends ScheduleEvent {
  final String department;
  final String semester;

  LoadStudentSchedulesEvent({
    required this.department,
    required this.semester,
  });
}
