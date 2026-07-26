import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/core/data/semester_subjects.dart';
import 'package:nexcampus_app/features/student/blocs/question_bank/screens/drive_webview_screen.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/models/course_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/repository/course_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/courses/services/course_service.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/model/note_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/repository/note_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/notes/services/note_service.dart';

/// Shows the courses a teacher has actually created (Firestore
/// `courses` collection, via the shared [CourseRepository]) for the
/// student's chosen department + the tapped semester — same live data
/// source `CoursesScreen` uses, so the two tabs never disagree.
///
/// Each course row has a dropdown ("Drive" / "Teacher Material"):
///  - "Drive" opens that course's Notes Drive-folder link, resolved via
///    [_subjectDataFor] + `getNotesLink` (`semester_subjects.dart`),
///    in the existing in-app `DriveWebViewScreen`.
///  - "Teacher Material" opens [_TeacherMaterialsScreen], which streams
///    the real notes the teacher uploaded for this course from the
///    `notes` Firestore collection (same collection the teacher's
///    `NoteScreen` writes to, matched by `courseId`).
class NotesSubjectScreen extends StatefulWidget {
  final int semester;

  /// Passed in directly from the department-selection step on
  /// `NotesScreen`. When null (e.g. if this screen is ever pushed from
  /// elsewhere without a selection), falls back to the student's own
  /// department from their profile — same as the Courses tab.
  final String? department;

  const NotesSubjectScreen({
    super.key,
    required this.semester,
    this.department,
  });

  @override
  State<NotesSubjectScreen> createState() => _NotesSubjectScreenState();
}

class _NotesSubjectScreenState extends State<NotesSubjectScreen> {
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
          _departmentError = 'You need to be signed in to view notes.';
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
  /// Same normalizer used by `CoursesScreen`, kept identical so a
  /// subject that matches on one tab matches on the other.
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
  /// local `semesterSubjects` map (`semester_subjects.dart`), so the
  /// Notes Drive link configured there can be resolved for this
  /// course. Returns `{}` when there's no match — `getNotesLink`
  /// already falls back to the shared root folder for an empty map.
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

  void _openDrive(CourseModel course) {
    final subjectData = _subjectDataFor(course);
    final notesLink = getNotesLink(subjectData);

    if (notesLink.isFallback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subject-specific notes coming soon — showing the general notes folder for now.',
          ),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriveWebViewScreen(
          title: '${course.courseName} Notes',
          url: notesLink.url,
        ),
      ),
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
        title: Text('Semester ${widget.semester} Notes'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),
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
                                  _openDrive(course);
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
/// writes to (via the shared `NoteRepository`/`NoteService`), matched
/// by `courseId` — this is the actual student <-> teacher notes
/// connection, not a Drive link.
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
///    document viewer inside an in-app WebView, since flutter_pdfview
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
    return _NoteWebViewBody(url: viewerUrl);
  }
}

/// Minimal WebView wrapper used only for the Google-Docs-viewer preview
/// of DOC/PPT files inside [_NoteViewerScreen]. (The "Drive" dropdown
/// option uses the app's existing `DriveWebViewScreen` instead — this
/// one is local to the Teacher Material file preview.)
class _NoteWebViewBody extends StatefulWidget {
  final String url;
  const _NoteWebViewBody({required this.url});

  @override
  State<_NoteWebViewBody> createState() => _NoteWebViewBodyState();
}

class _NoteWebViewBodyState extends State<_NoteWebViewBody> {
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
