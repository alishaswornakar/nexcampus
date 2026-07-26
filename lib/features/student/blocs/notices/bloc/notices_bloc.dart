import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/notices/models/notice_model.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notices/repository/teacher_notice_repository.dart';

<<<<<<< HEAD
=======
import '../models/notice_model.dart';
import '../repository/notice_repository.dart';
>>>>>>> caa77f0da2b9b39e33077d005b2bdd2c2f118c73
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
