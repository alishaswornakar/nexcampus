// lib/features/student/blocs/schedule/bloc/schedule_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';

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

  StreamSubscription<List<ScheduleModel>>? _scheduleSubscription;

  ScheduleBloc(this.repository) : super(ScheduleInitial()) {
    on<LoadStudentSchedulesEvent>(_onLoadStudentSchedules);
  }

  Future<void> _onLoadStudentSchedules(
    LoadStudentSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    await _scheduleSubscription?.cancel();

    _scheduleSubscription = repository
        .getStudentSchedule(
          department: event.department,
          semester: event.semester,
        )
        .listen(
      (schedules) {
        if (!isClosed) {
          emit(SchedulesLoaded(schedules));
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(ScheduleError(e.toString()));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _scheduleSubscription?.cancel();
    return super.close();
  }
}
