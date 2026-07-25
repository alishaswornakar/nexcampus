import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';

abstract class NoticeEvent {}

/// Load All Notices
class LoadNoticesEvent extends NoticeEvent {}

/// Add Notice
class AddNoticeEvent extends NoticeEvent {
  final NoticeModel notice;

  AddNoticeEvent(this.notice);
}

/// Update Notice
class UpdateNoticeEvent extends NoticeEvent {
  final NoticeModel notice;

  UpdateNoticeEvent(this.notice);
}

/// Delete Notice
class DeleteNoticeEvent extends NoticeEvent {
  final String noticeId;

  DeleteNoticeEvent(this.noticeId);
}

/// Pin / Unpin Notice
class ToggleNoticePinEvent extends NoticeEvent {
  final String noticeId;
  final bool isPinned;

  ToggleNoticePinEvent({
    required this.noticeId,
    required this.isPinned,
  });
}