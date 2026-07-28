import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/repository/teacher_notice_repository.dart';
import 'notices_event.dart';
import 'notices_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  final TeacherNoticeRepository repository;

  NoticeBloc(this.repository) : super(const NoticeInitial()) {
    on<LoadNoticesEvent>(_onLoadNotices);
  }

  /// Load All Notices
  Future<void> _onLoadNotices(
    LoadNoticesEvent event,
    Emitter<NoticeState> emit,
  ) async {
    emit(const NoticeLoading());

    await emit.forEach<List<TeacherNoticeModel>>(
      repository.getNotices(),
      onData: (notices) => NoticesLoaded(notices),
      onError: (error, stackTrace) => NoticeError(error.toString()),
    );
  }
}
