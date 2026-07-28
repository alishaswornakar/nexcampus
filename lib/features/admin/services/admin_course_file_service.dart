import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/core/services/cloudinary_service.dart'; // Add this import
import '../models/course_file_model.dart';

class AdminCourseFileService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'course_files';

  // 1. Upload File using Cloudinary
  static Future<String> uploadFileToStorage(File file, String fileName) async {
    final String? downloadUrl = await CloudinaryService.uploadFile(file);
    if (downloadUrl != null) {
      return downloadUrl;
    } else {
      throw Exception("Failed to upload file to Cloudinary.");
    }
  }

  // 2. Stream Course Files by Dept, Sem, Sec
  static Stream<List<CourseFileModel>> getCourseFiles({
    required String department,
    required String semester,
    required String section,
  }) {
    return _db
        .collection(_collection)
        .where('department', isEqualTo: department)
        .where('semester', isEqualTo: semester)
        .where('section', isEqualTo: section)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourseFileModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 3. Add New Course File
  static Future<void> addCourseFile(CourseFileModel fileModel) async {
    await _db.collection(_collection).add(fileModel.toMap());
  }

  // 4. Update Course File
  static Future<void> updateCourseFile(String id, String title, String subject) async {
    await _db.collection(_collection).doc(id).update({
      'title': title,
      'subject': subject,
    });
  }

  // 5. Delete Course File
  static Future<void> deleteCourseFile(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}