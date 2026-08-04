import 'package:flutter/material.dart';
import '../mocks/admin_preview_data.dart';
import '../models/submission_model.dart';
import '../models/course_file_model.dart';
import 'submission_detail_screen.dart';

class AdminPreviewScreen extends StatelessWidget {
  const AdminPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = AdminPreviewData.feedPosts();
    final subs = AdminPreviewData.submissions();
    final files = AdminPreviewData.courseFiles();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Preview'),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Feed Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...posts.map((p) => _mockFeedCard(context, p)).toList(),
          const SizedBox(height: 16),
          const Text('Submissions Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...subs.map((s) => _mockSubmissionTile(context, s)).toList(),
          const SizedBox(height: 16),
          const Text('Course Files Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...files.map((f) => _mockCourseFileTile(f)).toList(),
        ],
      ),
    );
  }

  Widget _mockFeedCard(BuildContext context, dynamic post) {
    // use simple card similar to admin feed
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(post.category),
        onTap: () {},
      ),
    );
  }

  Widget _mockSubmissionTile(BuildContext context, SubmissionModel s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(s.studentName.substring(0,1))),
        title: Text('${s.studentName} (${s.roll})'),
        subtitle: Text(s.isGraded ? 'Grade: ${s.grade}' : 'Not graded yet'),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SubmissionDetailScreen(submission: s, assignmentTitle: 'Preview Assignment')));
        },
      ),
    );
  }

  Widget _mockCourseFileTile(CourseFileModel f) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(f.title),
        subtitle: Text('By ${f.uploadedBy} • ${f.subject}'),
      ),
    );
  }
}
