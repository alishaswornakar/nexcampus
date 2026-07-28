import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/services/cloudinary_service.dart';
import '../models/notice_model.dart';
import 'package:flutter/foundation.dart';

class AdminNoticeService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'notices';

  // 📤 Attachment Upload (Fixed with Public Raw Support)
  static Future<String?> uploadNoticeAttachment(File file) async {
    try {
      final String? uploadedUrl = await CloudinaryService.uploadFile(file);
      return uploadedUrl;
    } catch (e) {
      debugPrint("Error uploading attachment: $e");
      return null;
    }
  }

  // ➕ Add Notice
  static Future<void> addNotice(NoticeModel notice) async {
    await _db.collection(_collection).add(notice.toMap());
  }

  // ✏️ Update Notice Details
  static Future<void> updateNotice(
    String id,
    String title,
    String description,
    String audience,
  ) async {
    await _db.collection(_collection).doc(id).update({
      'title': title,
      'description': description,
      'targetAudience': audience,
    });
  }

  // 📌 Toggle Pin/Unpin Notice
  static Future<void> togglePinNotice(String id, bool currentStatus) async {
    await _db.collection(_collection).doc(id).update({
      'isPinned': !currentStatus,
    });
  }

  // 🗑️ Delete Notice
  static Future<void> deleteNotice(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // 📋 Get Admin Notices (Sorted by Pinned first, then Created At)
  static Stream<List<NoticeModel>> getAdminNotices() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
              .toList();

          // Pin गरिएका नोटिसहरूलाई माथि (Top) ल्याउने Sort Logic
          list.sort((a, b) {
            if (a.isPinned == b.isPinned) {
              return b.createdAt.compareTo(a.createdAt);
            }
            return a.isPinned ? -1 : 1;
          });

          return list;
        });
  }

  // 👤 Get User Notices
  static Stream<List<NoticeModel>> getNoticesForUser(String role) {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
              .where(
                (notice) =>
                    notice.targetAudience == 'All' ||
                    notice.targetAudience.toLowerCase().contains(
                      role.toLowerCase(),
                    ),
              )
              .toList();

          list.sort((a, b) {
            if (a.isPinned == b.isPinned) {
              return b.createdAt.compareTo(a.createdAt);
            }
            return a.isPinned ? -1 : 1;
          });

          return list;
        });
  }
}
