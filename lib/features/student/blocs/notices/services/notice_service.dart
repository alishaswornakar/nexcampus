import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notice_model.dart';

/// Handles all Firestore reads for the Notices feature on the student side.
///
/// This points at the exact same `notices` collection the teacher feature
/// writes to (see `NoticeService` under `features/teachers/.../notices`).
/// Students never need to add/update/delete/pin, so this service is
/// intentionally read-only — that's the entire "connection" between the two
/// features: one collection, two consumers.
class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get noticesRef =>
      _firestore.collection("notices");

  /// Get All Notices (pinned first, newest first)
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
