import '../models/course_file_model.dart';
import '../models/submission_model.dart';
import '../../student/blocs/anonymous_issue_reporting/models/issue_post_model.dart';

class AdminPreviewData {
  static List<IssuePostModel> feedPosts() {
    final now = DateTime.now();
    return [
      IssuePostModel(
        id: 'p1',
        authorId: 'u1',
        anonymousName: 'Anonymous Panther',
        title: 'Cafeteria menu missing for today',
        body: 'Anyone knows why there is no menu posted for today?',
        category: 'Facility',
        isAnswer: false,
        isResolved: false,
        upvoteCount: 4,
        commentsCount: 2,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      IssuePostModel(
        id: 'p2',
        authorId: 'u2',
        anonymousName: 'Anonymous Eagle',
        title: 'Library timings conflict',
        body: 'The library closes earlier on Fridays which clashes with study groups.',
        category: 'Academic',
        isAnswer: false,
        isResolved: true,
        upvoteCount: 12,
        commentsCount: 6,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ];
  }

  static List<SubmissionModel> submissions() {
    final now = DateTime.now();
    return [
      SubmissionModel(
        id: 's1',
        assignmentId: 'a1',
        studentId: 'st1',
        studentName: 'Aarav Sharma',
        roll: 'CS-101',
        department: 'Computer',
        semester: '3rd',
        pdfUrl: '',
        pdfName: '',
        remarks: 'Please find attachment',
        submittedAt: now.subtract(const Duration(hours: 20)),
        grade: '',
        feedback: '',
      ),
      SubmissionModel(
        id: 's2',
        assignmentId: 'a1',
        studentId: 'st2',
        studentName: 'Sana Koirala',
        roll: 'CS-102',
        department: 'Computer',
        semester: '3rd',
        pdfUrl: '',
        pdfName: '',
        remarks: 'Submitted via app',
        submittedAt: now.subtract(const Duration(days: 2)),
        grade: 'A',
        feedback: 'Well done',
      ),
    ];
  }

  static List<CourseFileModel> courseFiles() {
    final now = DateTime.now();
    return [
      CourseFileModel(
        id: 'f1',
        title: 'Chapter 1 - Introduction',
        subject: 'Computer Basics',
        department: 'Computer',
        semester: '1st',
        section: 'A',
        fileUrl: '',
        uploadedBy: 'Prof. Sharma',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      CourseFileModel(
        id: 'f2',
        title: 'Chapter 2 - Data Structures',
        subject: 'Data Structures',
        department: 'Computer',
        semester: '3rd',
        section: 'A',
        fileUrl: '',
        uploadedBy: 'Prof. Rana',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
