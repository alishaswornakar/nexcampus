import '../models/notice_model.dart';
import '../services/notice_service.dart';

class NoticeRepository {
  final NoticeService service;

  NoticeRepository(this.service);

  /// Get All Notices
  Stream<List<NoticeModel>> getNotices() {
    return service.getNotices();
  }

  /// Get Single Notice
  Future<NoticeModel?> getNotice(
    String noticeId,
  ) {
    return service.getNotice(noticeId);
  }
}
