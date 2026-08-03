import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/course_file_model.dart';
import '../services/admin_course_file_service.dart';

// -----------------------------------------------------------------------------
// 1. OVERSIGHT SCREEN CONTENT (Handles Navigation inside Oversight Tab)
// -----------------------------------------------------------------------------
enum OversightView { list, attendance, publishedNotes, myCourseFiles }

class OversightScreenContent extends StatefulWidget {
  final VoidCallback onBackToHome;

  const OversightScreenContent({super.key, required this.onBackToHome});

  @override
  State<OversightScreenContent> createState() => _OversightScreenContentState();
}

class _OversightScreenContentState extends State<OversightScreenContent> {
  OversightView _currentView = OversightView.list;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentView == OversightView.list,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          if (_currentView == OversightView.myCourseFiles) {
            _currentView = OversightView.publishedNotes;
          } else {
            _currentView = OversightView.list;
          }
        });
      },
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      // 🎓 Published Notes View (Directly opened when clicking Course Files)
      case OversightView.publishedNotes:
        return _buildPublishedNotesScreen();

      // 📁 My Course Files Management View
      case OversightView.myCourseFiles:
        return CourseFileManagementScreen(
          onBack: () => setState(() {
            _currentView = OversightView.publishedNotes;
          }),
        );

      case OversightView.attendance:
        return Scaffold(
          appBar: AppBar(
            title: const Text("Attendance View"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _currentView = OversightView.list),
            ),
          ),
          body: const Center(child: Text("Attendance Screen Content")),
        );

      case OversightView.list:
      default:
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: widget.onBackToHome,
            ),
            title: const Text(
              'Oversight',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildOversightCard(
                title: 'Attendance',
                subtitle: 'View and monitor student attendance records.',
                icon: Icons.calendar_today_outlined,
                onTap: () => setState(() => _currentView = OversightView.attendance),
              ),
              const SizedBox(height: 14),
              _buildOversightCard(
                title: 'Course Files',
                subtitle: 'Review courses materials uploaded by administrators and teachers.',
                icon: Icons.folder_open_outlined,
                onTap: () {
                  // सिधै Published Notes खुल्नेछ
                  setState(() {
                    _currentView = OversightView.publishedNotes;
                  });
                },
              ),
              const SizedBox(height: 14),
              _buildOversightCard(
                title: 'Reports',
                subtitle: 'Review reported issues and administrative reports.',
                icon: Icons.article_outlined,
                onTap: () {},
              ),
            ],
          ),
        );
    }
  }

  // 📄 Published Notes UI (Screenshot wala Design)
  Widget _buildPublishedNotesScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => setState(() => _currentView = OversightView.list),
        ),
        title: const Text(
          'Published Notes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_shared_outlined, color: Color(0xFF3F51B5)),
            tooltip: "My Course Files",
            onPressed: () {
              setState(() {
                _currentView = OversightView.myCourseFiles;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          int count = docs.length;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3352E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reviewing ${count > 0 ? count : 6} Published Notes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Faculty uploads pending audit.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "12 New Today",
                            style: TextStyle(
                              color: Color(0xFF3352E0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "3 Departments",
                            style: TextStyle(
                              color: Color(0xFF3352E0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (docs.isEmpty) ...[
                _buildNoteCard(title: "Math", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "chapter 1", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "C Programming", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "notes", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "unit 1", author: "ranju", department: "General", url: ""),
                _buildNoteCard(title: "edc notes", author: "ranju", department: "General", url: ""),
              ] else ...[
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildNoteCard(
                    title: data['title'] ?? 'Untitled Note',
                    author: data['uploadedBy'] ?? data['author'] ?? 'Faculty',
                    department: data['department'] ?? 'General',
                    url: data['fileUrl'] ?? '',
                  );
                }),
              ],
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoteCard({
    required String title,
    required String author,
    required String department,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDBE2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF3F51B5),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "By $author",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  department,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.open_in_new_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
            onPressed: () async {
              if (url.isNotEmpty) {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOversightCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3F51B5),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF64748B),
          size: 22,
        ),
        onTap: onTap,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. COURSE FILE MANAGEMENT SCREEN (Functional Screen)
// -----------------------------------------------------------------------------
class CourseFileManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CourseFileManagementScreen({super.key, this.onBack});

  @override
  State<CourseFileManagementScreen> createState() =>
      _CourseFileManagementScreenState();
}

class _CourseFileManagementScreenState
    extends State<CourseFileManagementScreen> {
  String _selectedDepartment = 'Computer';
  String _selectedSemester = '1st';
  String _selectedSection = 'A';

  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];
  final List<String> _semesters8 = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th',
  ];
  final List<String> _semesters10 = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th',
  ];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  final ImagePicker _imagePicker = ImagePicker();

  List<String> _getAvailableSemesters() {
    return _selectedDepartment == 'Architecture' ? _semesters10 : _semesters8;
  }

  Future<void> _openFileUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open the file link.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening file: $e")),
        );
      }
    }
  }

  Future<void> _showAttachmentSourcePicker({
    required Function(File file, String name) onFilePicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10),
            child: Wrap(
              children: [
                const Center(
                  child: Text(
                    "Choose Attachment Source",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  title: const Text("Take Photo (Camera)"),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final XFile? photo = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (photo != null) {
                      onFilePicked(File(photo.path), photo.name);
                    }
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Icons.photo_library, color: Colors.amber),
                  ),
                  title: const Text("Choose Image from Gallery"),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final XFile? image = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      onFilePicked(File(image.path), image.name);
                    }
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.attach_file, color: Colors.green),
                  ),
                  title: const Text("Browse Document (PDF, DOC, PPT...)"),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: [
                        'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'ppt', 'pptx',
                      ],
                    );
                    if (result != null && result.files.single.path != null) {
                      onFilePicked(
                        File(result.files.single.path!),
                        result.files.single.name,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddOrEditDialog({CourseFileModel? existingFile}) {
    final titleController = TextEditingController(text: existingFile?.title ?? '');
    final subjectController = TextEditingController(text: existingFile?.subject ?? '');

    File? selectedFile;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                existingFile == null ? "Add Course File / Note" : "Edit File Details",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "File Title (e.g. Chapter 1 Notes)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: "Subject Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (existingFile == null) ...[
                      const Text(
                        "Attach Note / Document:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: isUploading
                            ? null
                            : () {
                                _showAttachmentSourcePicker(
                                  onFilePicked: (file, name) {
                                    setDialogState(() {
                                      selectedFile = file;
                                      selectedFileName = name;
                                    });
                                  },
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.shade50,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add_a_photo_outlined, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedFileName ?? "Tap to capture photo or pick PDF/File...",
                                  style: TextStyle(
                                    color: selectedFileName == null
                                        ? Colors.grey.shade700
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: selectedFileName == null
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (isUploading) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text("Uploading file, please wait...", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a file title")),
                            );
                            return;
                          }

                          if (existingFile == null && selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please attach a file or capture photo first")),
                            );
                            return;
                          }

                          setDialogState(() => isUploading = true);

                          try {
                            if (existingFile == null) {
                              String downloadUrl = await AdminCourseFileService.uploadFileToStorage(
                                selectedFile!,
                                selectedFileName!,
                              );

                              final newFile = CourseFileModel(
                                id: '',
                                title: titleController.text.trim(),
                                subject: subjectController.text.trim(),
                                department: _selectedDepartment,
                                semester: _selectedSemester,
                                section: _selectedSection,
                                fileUrl: downloadUrl,
                                uploadedBy: 'Admin',
                                createdAt: DateTime.now(),
                              );
                              await AdminCourseFileService.addCourseFile(newFile);
                            } else {
                              await AdminCourseFileService.updateCourseFile(
                                existingFile.id,
                                titleController.text.trim(),
                                subjectController.text.trim(),
                              );
                            }

                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            setDialogState(() => isUploading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Upload failed: $e")),
                            );
                          }
                        },
                  child: Text(existingFile == null ? "Upload & Save" : "Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "My Course Files",
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B52D4),
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // FILTERS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Dept",
                      labelStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    items: _departments
                        .map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDepartment = val!;
                        if (!_getAvailableSemesters().contains(_selectedSemester)) {
                          _selectedSemester = '1st';
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedSemester,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Sem",
                      labelStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    items: _getAvailableSemesters()
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSemester = val!),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedSection,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Sec",
                      labelStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    items: _sections
                        .map((sec) => DropdownMenuItem(value: sec, child: Text(sec, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSection = val!),
                  ),
                ),
              ],
            ),
          ),

          // STREAM LIST
          Expanded(
            child: StreamBuilder<List<CourseFileModel>>(
              stream: AdminCourseFileService.getCourseFiles(
                department: _selectedDepartment,
                semester: _selectedSemester,
                section: _selectedSection,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No course files found for this section."),
                  );
                }

                final files = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insert_drive_file_outlined,
                            color: Color(0xFF3B52D4),
                          ),
                        ),
                        title: Text(
                          file.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          "Subject: ${file.subject}\nBy: ${file.uploadedBy}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'view') {
                              _openFileUrl(file.fileUrl);
                            } else if (value == 'edit') {
                              _showAddOrEditDialog(existingFile: file);
                            } else if (value == 'share') {
                              if (file.fileUrl.isNotEmpty) {
                                await Share.share(
                                  "Check out this course file: ${file.title}\nLink: ${file.fileUrl}",
                                );
                              }
                            } else if (value == 'delete') {
                              await AdminCourseFileService.deleteCourseFile(file.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'view', child: Text("View/Open")),
                            const PopupMenuItem(value: 'edit', child: Text("Edit")),
                            const PopupMenuItem(value: 'share', child: Text("Share")),
                            const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}