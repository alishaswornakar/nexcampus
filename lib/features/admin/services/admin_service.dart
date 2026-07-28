import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/admin/models/student_model.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Student Add गर्ने ('studentData' Collection मा)
  static Future<void> addStudent(StudentModel student) async {
    try {
      // Data Map तयार गर्ने
      final Map<String, dynamic> studentData = student.toMap();

      // Fallback values यदि केही नमिलेमा
      studentData['role'] = 'student';
      if ((studentData['department'] ?? '').isEmpty)
        studentData['department'] = 'Computer';
      if ((studentData['semester'] ?? '').isEmpty)
        studentData['semester'] = '1';
      if ((studentData['section'] ?? '').isEmpty) studentData['section'] = 'A';

      // 'studentData' Collection मा document थप्ने
      await _db.collection('studentData').add(studentData);
    } catch (e) {
      debugPrint("Error adding student: $e");
      rethrow;
    }
  }

  // 2. Firestore बाट All Students ल्याउने
  static Future<List<StudentModel>> getStudents() async {
    try {
      final QuerySnapshot snapshot = await _db.collection('studentData').get();

      final List<StudentModel> studentsList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StudentModel.fromMap(data, doc.id);
      }).toList();

      return studentsList;
    } catch (e) {
      debugPrint("Error fetching students: $e");
      return [];
    }
  }

  // 3. Filter गरेर Student List ल्याउने (Client-side)
  static Future<List<StudentModel>> getFilteredStudents({
    String? department,
    String? semester,
    String? section,
  }) async {
    try {
      final List<StudentModel> allStudents = await getStudents();

      return allStudents.where((student) {
        if (department != null &&
            department.isNotEmpty &&
            student.department.toLowerCase().trim() !=
                department.toLowerCase().trim()) {
          return false;
        }
        if (semester != null &&
            semester.isNotEmpty &&
            student.semester.trim() != semester.trim()) {
          return false;
        }
        if (section != null &&
            section.isNotEmpty &&
            student.section.toLowerCase().trim() !=
                section.toLowerCase().trim()) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      debugPrint("Error filtering students: $e");
      return [];
    }
  }
}
