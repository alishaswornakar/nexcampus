import '../models/notice_model.dart';
import '../services/notice_service.dart';

class NoticeRepository {
  final NoticeService service;

  NoticeRepository(this.service);

  /// Add Notice
  Future<void> addNotice(
    NoticeModel notice,
  ) async {
    await service.addNotice(notice);
  }

  /// Update Notice
  Future<void> updateNotice(
    NoticeModel notice,
  ) async {
    await service.updateNotice(notice);
  }

  /// Delete Notice
  Future<void> deleteNotice(
    String noticeId,
  ) async {
    await service.deleteNotice(noticeId);
  }

  /// Pin / Unpin Notice
  Future<void> togglePinned({
    required String noticeId,
    required bool isPinned,
  }) async {
    await service.togglePinned(
      noticeId: noticeId,
      isPinned: isPinned,
    );
  }

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