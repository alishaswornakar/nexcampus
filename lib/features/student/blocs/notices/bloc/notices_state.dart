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
  final List<NoticeModel> notices;

  const NoticesLoaded(this.notices);
}

/// Error
class NoticeError extends NoticeState {
  final String message;

  const NoticeError(this.message);
}
