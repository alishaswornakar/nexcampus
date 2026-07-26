import 'package:nexcampus_app/features/teachers/teachers_features/notices/models/notice_model.dart';

import '../models/notice_model.dart';

abstract class NoticeState {
  const NoticeState();
}

/// Initial State
class NoticeInitial extends NoticeState {
  const NoticeInitial();
}

/// Loading
class NoticeLoading extends NoticeState {
  const NoticeLoading();
}

/// Loaded
class NoticesLoaded extends NoticeState {
  final List<TeacherNoticeModel> notices;

  const NoticesLoaded(this.notices);
}

/// Error
class NoticeError extends NoticeState {
  final String message;

  const NoticeError(this.message);
}
