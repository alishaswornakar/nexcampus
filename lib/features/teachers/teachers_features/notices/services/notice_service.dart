import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notice_model.dart';

class NoticeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get noticesRef =>
          _firestore.collection("notices");

  /// Add Notice
  Future<void> addNotice(
    NoticeModel notice,
  ) async {
    await noticesRef.doc(notice.id).set(
          notice.toMap(),
        );
  }

  /// Update Notice
  Future<void> updateNotice(
    NoticeModel notice,
  ) async {
    await noticesRef.doc(notice.id).update(
          notice.toMap(),
        );
  }

  /// Delete Notice
  Future<void> deleteNotice(
    String noticeId,
  ) async {
    await noticesRef.doc(noticeId).delete();
  }

  /// Pin / Unpin Notice
  Future<void> togglePinned({
    required String noticeId,
    required bool isPinned,
  }) async {
    await noticesRef.doc(noticeId).update({
      "isPinned": isPinned,
    });
  }

  /// Get All Notices
  Stream<List<NoticeModel>> getNotices() {
    return noticesRef
        .orderBy(
          "isPinned",
          descending: true,
        )
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NoticeModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Get Single Notice
  Future<NoticeModel?> getNotice(
    String noticeId,
  ) async {
    final doc = await noticesRef.doc(noticeId).get();

    if (!doc.exists) {
      return null;
    }

    return NoticeModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }
}