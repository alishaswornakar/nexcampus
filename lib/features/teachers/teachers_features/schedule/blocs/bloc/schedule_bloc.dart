import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/repository/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository repository;

  StreamSubscription<List<ScheduleModel>>? _scheduleSubscription;

  ScheduleBloc(this.repository) : super(ScheduleInitial()) {
    on<LoadSchedulesEvent>(_onLoadSchedules);

    on<LoadTeacherSchedulesEvent>(_onLoadTeacherSchedules);

    on<LoadStudentSchedulesEvent>(_onLoadStudentSchedules);

    on<AddScheduleEvent>(_onAddSchedule);

    on<UpdateScheduleEvent>(_onUpdateSchedule);

    on<DeleteScheduleEvent>(_onDeleteSchedule);
  }

  /// Load Department + Semester Schedule
  Future<void> _onLoadSchedules(
    LoadSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    await _scheduleSubscription?.cancel();

    _scheduleSubscription = repository
        .getSchedule(
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

  /// Teacher Schedule
  Future<void> _onLoadTeacherSchedules(
    LoadTeacherSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    await _scheduleSubscription?.cancel();

    _scheduleSubscription = repository
        .getTeacherSchedule(
          teacherId: event.teacherId,
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

  /// Student Schedule
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

  /// Add Schedule
  Future<void> _onAddSchedule(
    AddScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await repository.createSchedule(
        schedule: event.schedule,
      );

      emit(ScheduleAdded());
    } catch (e) {
      emit(
        ScheduleError(e.toString()),
      );
    }
  }

  /// Update Schedule
  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await repository.updateSchedule(
        schedule: event.schedule,
      );

      emit(ScheduleUpdated());
    } catch (e) {
      emit(
        ScheduleError(e.toString()),
      );
    }
  }

  /// Delete Schedule
  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      await repository.deleteSchedule(
        event.scheduleId,
      );

      emit(ScheduleDeleted());
    } catch (e) {
      emit(
        ScheduleError(e.toString()),
      );
    }
  }

  @override
  Future<void> close() async {
    await _scheduleSubscription?.cancel();
    return super.close();
  }
}