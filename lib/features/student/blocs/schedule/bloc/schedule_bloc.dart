// lib/features/student/blocs/schedule/bloc/schedule_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/repository/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

/// Read-only counterpart of the teacher's ScheduleBloc. Same
/// subscribe-and-emit shape (LoadStudentSchedulesEvent -> Loading ->
/// SchedulesLoaded/Error), just without Add/Update/Delete since the
/// student side never writes schedule data.
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository repository;

  ScheduleBloc(this.repository) : super(ScheduleInitial()) {
    debugPrint("===== ScheduleBloc CREATED =====");

    on<LoadStudentSchedulesEvent>(_onLoadStudentSchedules);
  }

  Future<void> _onLoadStudentSchedules(
    LoadStudentSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    // emit.forEach keeps this handler "alive" for as long as the
    // Firestore stream is open, so emit() stays valid when new
    // snapshots arrive later. The previous approach used a bare
    // .listen() and returned immediately — bloc considered the handler
    // "completed" right away, so any later emit() from the listener
    // callback threw `emit was called after an event handler completed
    // normally`. emit.forEach also handles subscription cancellation
    // automatically (on bloc close, or when this handler is replaced),
    // so the manual StreamSubscription field is no longer needed.
    await emit.forEach<List<ScheduleModel>>(
      repository.getStudentSchedule(
        department: event.department,
        semester: event.semester,
      ),
      onData: (schedules) => SchedulesLoaded(schedules),
      onError: (error, stackTrace) => ScheduleError(error.toString()),
    );
  }
}
