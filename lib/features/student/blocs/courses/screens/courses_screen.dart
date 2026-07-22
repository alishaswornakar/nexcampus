import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/core/data/semester_subjects.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDashboardScreen(user: currentUser),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Courses'),
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBar:  AppBottomNavBar(
          currentIndex: 1
        ),
        body: ListView.separated(
          padding: EdgeInsets.all(size.width * 0.04),
          itemCount: 8,
          separatorBuilder: (_, __) => SizedBox(height: size.height * 0.015),
          itemBuilder: (context, index) {
            final semester = index + 1;
            return _buildSemesterTile(context, semester, size);
          },
        ),
      ),
    );
  }

  Widget _buildSemesterTile(BuildContext context, int semester, Size size) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _SubjectsScreen(semester: semester),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.018,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: size.width * 0.06,
                backgroundColor: const Color(0xFF1B4F9B),
                child: Text(
                  '$semester',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.045,
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: Text(
                  'Semester $semester',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Color(0xFF1B4F9B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectsScreen extends StatelessWidget {
  final int semester;
  const _SubjectsScreen({required this.semester});

  @override
  Widget build(BuildContext context) {
    final subjects = semesterSubjects[semester] ?? [];
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Semester $semester Subjects'),
        backgroundColor: const Color(0xFF1B4F9B),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(size.width * 0.04),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.012,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1B4F9B),
                    radius: size.width * 0.05,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: Text(
                      subject['name']!,
                      style: TextStyle(
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _SyllabusPdfScreen(
                          assetPath: subject['pdf']!,
                          title: subject['name']!,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4F9B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                        vertical: size.height * 0.008,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Syllabus',
                      style: TextStyle(fontSize: size.width * 0.03),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SyllabusPdfScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  const _SyllabusPdfScreen({required this.assetPath, required this.title});

  @override
  State<_SyllabusPdfScreen> createState() => _SyllabusPdfScreenState();
}

class _SyllabusPdfScreenState extends State<_SyllabusPdfScreen> {
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final data = await DefaultAssetBundle.of(context).load(widget.assetPath);
      final bytes = data.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final fileName = widget.assetPath.split('/').last;
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      setState(() => _localPath = file.path);
    } catch (e) {
      setState(() => _error = 'Syllabus PDF not available yet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF1B4F9B),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : _localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(filePath: _localPath!),
    );
  }
}
