import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/notice_model.dart';
import '../../repository/teacher_notice_repository.dart';
import 'package:nexcampus_app/features/student/blocs/notification/models/notification_model.dart';
import 'package:nexcampus_app/features/student/blocs/notification/services/notification_service.dart';
import 'notices_event.dart';
import 'notices_state.dart';

class NoticeBloc extends Bloc<NoticeEvent, NoticeState> {
  final TeacherNoticeRepository repository;

  NoticeBloc(this.repository) : super(const NoticeInitial()) {
    on<LoadNoticesEvent>(_onLoadNotices);

    on<AddNoticeEvent>(_onAddNotice);

    on<UpdateNoticeEvent>(_onUpdateNotice);

    on<DeleteNoticeEvent>(_onDeleteNotice);

    on<ToggleNoticePinEvent>(_onTogglePinned);
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

  /// Add Notice
  Future<void> _onAddNotice(
    AddNoticeEvent event,
    Emitter<NoticeState> emit,
  ) async {
    try {
      await repository.addNotice(event.notice);

      try {
        await NotificationService().createNotification(
          NotificationModel(
            id: '',
            title: event.notice.isPinned
                ? "📌 ${event.notice.title}"
                : event.notice.title,
            body: event.notice.description,
            type: NotificationType.notice,
            targetType: NotificationTargetType.all,
            senderId: event.notice.teacherId,
            senderName: event.notice.teacherName,
            createdAt: DateTime.now(),
          ),
        );
      } catch (_) {}

      emit(const NoticeAdded());
    } catch (e) {
      emit(NoticeError(e.toString()));
    }
  }

  /// Update Notice
  Future<void> _onUpdateNotice(
    UpdateNoticeEvent event,
    Emitter<NoticeState> emit,
  ) async {
    try {
      await repository.updateNotice(event.notice);

      emit(const NoticeUpdated());
    } catch (e) {
      emit(NoticeError(e.toString()));
    }
  }

  /// Delete Notice
  Future<void> _onDeleteNotice(
    DeleteNoticeEvent event,
    Emitter<NoticeState> emit,
  ) async {
    try {
      await repository.deleteNotice(event.noticeId);

      emit(const NoticeDeleted());
    } catch (e) {
      emit(NoticeError(e.toString()));
    }
  }

  /// Pin / Unpin
  Future<void> _onTogglePinned(
    ToggleNoticePinEvent event,
    Emitter<NoticeState> emit,
  ) async {
    try {
      await repository.togglePinned(
        noticeId: event.noticeId,
        isPinned: event.isPinned,
      );
    } catch (e) {
      emit(NoticeError(e.toString()));
    }
  }
}
