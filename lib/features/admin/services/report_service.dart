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
    );
    await docRef.set(newReport.toMap());
  }

  // 2. Admin को लागि सबै Reports Fetch गर्ने (Stream)
  Stream<List<ReportModel>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 3. Specific Student को Reports Fetch गर्ने (Stream)
  Stream<List<ReportModel>> getStudentReports(String studentId) {
    return _firestore
        .collection('reports')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // 4. Admin ले Feedback र Status Update गर्ने
  Future<void> updateReportFeedback(
      String reportId, String status, String feedback) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': status,
      'adminFeedback': feedback,
    });
  }
}