import '../models/notice_model.dart';
import '../services/teacher_notice_service.dart';

class TeacherNoticeRepository {
  final TeacherNoticeService service;

  TeacherNoticeRepository(this.service);

  /// Add Notice
  Future<void> addNotice(
    TeacherNoticeModel notice,
  ) async {
    await service.addNotice(notice);
  }

  /// Update Notice
  Future<void> updateNotice(
    TeacherNoticeModel notice,
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
  Stream<List<TeacherNoticeModel>> getNotices() {
    return service.getNotices();
  }

  /// Get Single Notice
  Future<TeacherNoticeModel?> getNotice(
    String noticeId,
  ) {
    return service.getNotice(noticeId);
  }
}