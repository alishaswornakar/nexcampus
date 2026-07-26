// student/courses/screens/courses_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nexcampus_app/features/student/widgets/bottom_nav_bar.dart';
import 'package:nexcampus_app/features/student/screens/student_dashboard_screen.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/core/data/semester_subjects.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/models/course_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/repository/course_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/services/course_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/services/note_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // Same department -> semester-count map used on the teacher side
  // (department_semester_selection_screen.dart), so the two flows stay
  // in sync.
  final Map<String, int> _departments = const {
    "Computer Engineering": 8,
    "Civil Engineering": 8,
    "Architecture Engineering": 10,
  };

  String? _selectedDepartment;

  IconData _iconFor(String department) {
    if (department.contains('Computer')) return Icons.computer_rounded;
    if (department.contains('Civil')) return Icons.engineering_rounded;
    return Icons.architecture_rounded;
  }

  void _openSemester(int semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SubjectsScreen(
          semester: semester,
          department: _selectedDepartment!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Courses'),
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Department',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your department to continue.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ..._departments.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _departmentCard(
                    title: entry.key,
                    semesterCount: entry.value,
                    icon: _iconFor(entry.key),
                  ),
                ),
              ),
              if (_selectedDepartment != null) ...[
                const SizedBox(height: 10),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 20),
                const Text(
                  'Choose Semester',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a semester to view its courses.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _departments[_selectedDepartment]!,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 2.3,
                  ),
                  itemBuilder: (context, index) {
                    final semester = index + 1;
                    return _semesterChip(semester);
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _departmentCard({
    required String title,
    required int semesterCount,
    required IconData icon,
  }) {
    final selected = _selectedDepartment == title;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => setState(() => _selectedDepartment = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppTheme.secondary.withValues(alpha: 0.08),
              child: Icon(
                icon,
                color: selected ? Colors.white : AppTheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$semesterCount Semesters',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _semesterChip(int semester) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openSemester(semester),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Semester $semester',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the courses a teacher has actually created (Firestore `courses`
/// collection, via the shared [CourseRepository]) for the student's own
/// department + the tapped semester.
///
/// Each course row has a dropdown ("Drive" / "Teacher Material"):
///  - "Drive" opens a sheet with Syllabus / Notes / QNB buttons. These
///    are Google Drive **folder** links (configured in
///    `semester_data1.dart`), so they're opened in an in-app WebView
///    (`_AppWebViewScreen`) rather than a PDF viewer.
///  - "Teacher Material" opens `_TeacherMaterialsScreen`, which streams
///    the real notes the teacher uploaded for this course from the
///    `notes` Firestore collection (same collection the teacher's
///    `NoteScreen` writes to), and lets the student open each file.
class _SubjectsScreen extends StatefulWidget {
  final int semester;

  /// Passed in directly from the new department-selection step on
  /// [CoursesScreen]. When null (e.g. if this screen is ever pushed from
  /// elsewhere without a selection), falls back to the student's own
  /// department from their profile, same as before.
  final String? department;

  const _SubjectsScreen({required this.semester, this.department});

  @override
  State<_SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<_SubjectsScreen> {
  final CourseRepository _repository = CourseRepository(CourseService());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _department;
  bool _loadingDepartment = true;
  String? _departmentError;

  @override
  void initState() {
    super.initState();
    if (widget.department != null && widget.department!.trim().isNotEmpty) {
      _department = widget.department;
      _loadingDepartment = false;
    } else {
      _loadDepartment();
    }
  }

  Future<void> _loadDepartment() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        setState(() {
          _departmentError = 'You need to be signed in to view courses.';
          _loadingDepartment = false;
        });
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      final department = userDoc.data()?['department'] as String?;

      setState(() {
        _department = department;
        _loadingDepartment = false;
        if (department == null || department.trim().isEmpty) {
          _departmentError = 'Your department is not set on your profile yet.';
        }
      });
    } catch (e) {
      setState(() {
        _departmentError = 'Failed to load your department: $e';
        _loadingDepartment = false;
      });
    }
  }

  /// Normalizes a subject/course string so matching survives common
  /// real-world typos: casing, punctuation, extra spaces, and roman
  /// numerals typed as digits (e.g. "Calculus I" vs "Calculus 1").
  String _normalize(String input) {
    var s = input.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[^\w\s]'), ''); // strip punctuation
    s = s.replaceAll(RegExp(r'\s+'), ' '); // collapse whitespace

    const romanToDigit = {
      ' i': ' 1',
      ' ii': ' 2',
      ' iii': ' 3',
      ' iv': ' 4',
      ' v': ' 5',
    };
    for (final entry in romanToDigit.entries) {
      if (s.endsWith(entry.key)) {
        s = s.substring(0, s.length - entry.key.length) + entry.value;
        break;
      }
    }
    return s.trim();
  }

  /// Loosely matches a live Firestore [CourseModel] to an entry in the
  /// local `semesterSubjects` map (semester_data1.dart), so the Drive
  /// links (syllabus/notes/qnb) configured there can be resolved for
  /// this course. Returns `{}` when there's no match — the
  /// `getSyllabusLink` / `getNotesLink` / `getQnbLink` helpers already
  /// fall back to the shared root/QNB folders for an empty/partial map.
  Map<String, String> _subjectDataFor(CourseModel course) {
    final subjects = semesterSubjects[widget.semester] ?? [];
    final courseName = _normalize(course.courseName);
    final courseCode = _normalize(course.courseCode);

    for (final subject in subjects) {
      final name = _normalize(subject['name'] ?? '');
      final shortName = _normalize(subject['shortName'] ?? '');

      if (name.isEmpty) continue;

      final matches =
          name == courseName ||
          (shortName.isNotEmpty &&
              (shortName == courseCode || shortName == courseName)) ||
          courseName.contains(name) ||
          (courseName.isNotEmpty && name.contains(courseName));

      if (matches) return subject;
    }
    return const {};
  }

  void _openInWebView(String title, SubjectLink link) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AppWebViewScreen(title: title, url: link.url),
      ),
    );
  }

  void _showDriveOptions(CourseModel course) {
    final subjectData = _subjectDataFor(course);
    final syllabusLink = getSyllabusLink(subjectData);
    final notesLink = getNotesLink(subjectData);
    final qnbLink = getQnbLink(subjectData);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    course.courseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _driveOptionTile(
                  icon: Icons.description_outlined,
                  label: 'Syllabus',
                  isFallback: syllabusLink.isFallback,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openInWebView(
                      'Syllabus · ${course.courseName}',
                      syllabusLink,
                    );
                  },
                ),
                _driveOptionTile(
                  icon: Icons.note_alt_outlined,
                  label: 'Notes',
                  isFallback: notesLink.isFallback,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openInWebView('Notes · ${course.courseName}', notesLink);
                  },
                ),
                _driveOptionTile(
                  icon: Icons.quiz_outlined,
                  label: 'QNB',
                  isFallback: qnbLink.isFallback,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openInWebView('QNB · ${course.courseName}', qnbLink);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _driveOptionTile({
    required IconData icon,
    required String label,
    required bool isFallback,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1B4F9B)),
      title: Text(label),
      subtitle: isFallback ? const Text('Shared folder') : null,
      trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showTeacherMaterial(CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TeacherMaterialsScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Semester ${widget.semester} Courses'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: _loadingDepartment
          ? const Center(child: CircularProgressIndicator())
          : _departmentError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _departmentError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          : StreamBuilder<List<CourseModel>>(
              stream: _repository.getCourses(
                department: _department!,
                semester: '${widget.semester}',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }

                final courses = snapshot.data ?? [];

                if (courses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 56,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No courses added for this semester yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(size.width * 0.04),
                  itemCount: courses.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: size.height * 0.012),
                  itemBuilder: (context, index) {
                    final course = courses[index];

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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.courseName,
                                    style: TextStyle(
                                      fontSize: size.width * 0.038,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${course.courseCode} · ${course.teacherName}',
                                    style: TextStyle(
                                      fontSize: size.width * 0.03,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: Color(0xFF1B4F9B),
                              ),
                              onSelected: (value) {
                                if (value == 'drive') {
                                  _showDriveOptions(course);
                                } else if (value == 'teacher_material') {
                                  _showTeacherMaterial(course);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'drive',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cloud_outlined,
                                        color: Color(0xFF1B4F9B),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Drive'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'teacher_material',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.upload_file_outlined,
                                        color: Color(0xFF1B4F9B),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Teacher Material'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// Lists the real files a teacher has uploaded for [course], read live
/// from the same `notes` Firestore collection the teacher's `NoteScreen`
/// writes to (via the shared `NoteRepository`/`NoteService`).
class _TeacherMaterialsScreen extends StatelessWidget {
  final CourseModel course;
  const _TeacherMaterialsScreen({required this.course});

  @override
  Widget build(BuildContext context) {
    final repository = NoteRepository(NoteService());

    return Scaffold(
      appBar: AppBar(
        title: Text('${course.courseName} · Materials'),
        backgroundColor: const Color(0xFF1B4F9B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: repository.getNotes(courseId: course.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No material uploaded by the teacher yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = notes[index];
              return _NoteTile(
                note: note,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _NoteViewerScreen(note: note),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  const _NoteTile({required this.note, required this.onTap});

  IconData _fileIcon() {
    final name = note.fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.doc') || name.endsWith('.docx')) {
      return Icons.description;
    }
    if (name.endsWith('.ppt') || name.endsWith('.pptx')) {
      return Icons.slideshow;
    }
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      return Icons.image;
    }
    return Icons.insert_drive_file;
  }

  Color _iconColor() {
    final name = note.fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Colors.red;
    if (name.endsWith('.ppt') || name.endsWith('.pptx')) return Colors.orange;
    if (name.endsWith('.doc') || name.endsWith('.docx')) return Colors.blue;
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      return Colors.green;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _iconColor().withValues(alpha: 0.12),
                child: Icon(_fileIcon(), color: _iconColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            note.uploadedBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(note.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens a single [NoteModel]'s uploaded file, picking the right viewer
/// by extension:
///  - `.pdf`  -> downloaded and shown with flutter_pdfview
///  - images  -> shown with Image.network directly
///  - others (.doc/.docx/.ppt/.pptx/unknown) -> shown via Google's
///    document viewer inside the in-app WebView, since flutter_pdfview
///    can only render PDF bytes.
class _NoteViewerScreen extends StatefulWidget {
  final NoteModel note;
  const _NoteViewerScreen({required this.note});

  @override
  State<_NoteViewerScreen> createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends State<_NoteViewerScreen> {
  String? _localPdfPath;
  String? _error;
  bool _loading = true;

  bool get _isPdf => widget.note.fileName.toLowerCase().endsWith('.pdf');

  bool get _isImage {
    final name = widget.note.fileName.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png');
  }

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      _downloadPdf();
    } else {
      _loading = false;
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.note.fileUrl));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.note.fileName}');
      await file.writeAsBytes(response.bodyBytes);
      if (!mounted) return;
      setState(() {
        _localPdfPath = file.path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not open this file: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF1B4F9B),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    if (_isPdf && _localPdfPath != null) {
      return PDFView(filePath: _localPdfPath!);
    }

    if (_isImage) {
      return InteractiveViewer(
        child: Center(
          child: Image.network(
            widget.note.fileUrl,
            errorBuilder: (_, __, ___) => const Text(
              'Could not load this image.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // DOC/DOCX/PPT/PPTX and anything else flutter_pdfview can't handle.
    final viewerUrl =
        'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(widget.note.fileUrl)}';
    return _AppWebViewBody(url: viewerUrl);
  }
}

/// Opens a Google Drive folder link (Syllabus / Notes / QNB) or any
/// other page inside the app using a WebView, instead of leaving the
/// app via url_launcher.
class _AppWebViewScreen extends StatelessWidget {
  final String title;
  final String url;
  const _AppWebViewScreen({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF1B4F9B),
        foregroundColor: Colors.white,
      ),
      body: _AppWebViewBody(url: url),
    );
  }
}

/// The WebView + loading/error state, factored out so it can be reused
/// both as a full screen (`_AppWebViewScreen`) and embedded inside
/// `_NoteViewerScreen` for DOC/PPT previews.
class _AppWebViewBody extends StatefulWidget {
  final String url;
  const _AppWebViewBody({required this.url});

  @override
  State<_AppWebViewBody> createState() => _AppWebViewBodyState();
}

class _AppWebViewBodyState extends State<_AppWebViewBody> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _error = 'Could not load this page (${error.description}).';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

/// Downloads a bundled asset PDF and displays it with flutter_pdfview.
/// Kept for the "Syllabus" local-fallback flow if you re-enable it;
/// not currently referenced by the Drive/Teacher-Material dropdown.
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
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
