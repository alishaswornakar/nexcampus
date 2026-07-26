part of 'schedule_bloc.dart';

abstract class ScheduleState {}

/// Initial
class ScheduleInitial extends ScheduleState {}

/// Loading
class ScheduleLoading extends ScheduleState {}

/// Loaded
class SchedulesLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;

  SchedulesLoaded(this.schedules);
}

/// Add Success
class ScheduleAdded extends ScheduleState {}

/// Update Success
class ScheduleUpdated extends ScheduleState {}

/// Delete Success
class ScheduleDeleted extends ScheduleState {}

/// Error
class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError(this.message);
}
