import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Student ले Report Create गर्ने
  Future<void> submitReport(ReportModel report) async {
    final docRef = _firestore.collection('reports').doc();
    final newReport = ReportModel(
      id: docRef.id,
      studentId: report.studentId,
      studentName: report.studentName,
      title: report.title,
      description: report.description,
      status: 'Pending',
      adminFeedback: '',
      createdAt: DateTime.now(),
      updatedAt: null,
      isAnonymous: report.isAnonymous,
      category: report.category,
    );
    await docRef.set(newReport.toMap());
  }

  // 2. Admin को लागि सबै Reports Fetch गर्ने (Stream)
  Stream<List<ReportModel>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // 3. Specific Student को Reports Fetch गर्ने (Stream)
  // NOTE: where() + orderBy() on different fields needs a Firestore
  // composite index (studentId ASC, createdAt DESC). Firestore will
  // print a console link to auto-create it the first time this query
  // runs if it doesn't exist yet.
  Stream<List<ReportModel>> getStudentReports(
    String studentId, {
    String? statusFilter,
  }) {
    Query query = _firestore
        .collection('reports')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true);

    // Apply status filter if provided and not 'All'
    if (statusFilter != null && statusFilter != 'All') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                ReportModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  // 4. Admin ले Feedback र Status Update गर्ने
  Future<void> updateReportFeedback(
    String reportId,
    String status,
    String feedback,
  ) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': status,
      'adminFeedback': feedback,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 5. Delete report (Admin use)
  Future<void> deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
