import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../models/course_file_model.dart';
import '../services/admin_course_file_service.dart';

class CourseFileManagementScreen extends StatefulWidget {
  const CourseFileManagementScreen({super.key});

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
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
  ];
  final List<String> _semesters10 = [
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
  ];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  final ImagePicker _imagePicker = ImagePicker();

  List<String> _getAvailableSemesters() {
    return _selectedDepartment == 'Architecture' ? _semesters10 : _semesters8;
  }

  // 🔗 Helper Function: Cloudinary Link / File Link Open गर्ने
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error opening file: $e")));
      }
    }
  }

  // Camera / Gallery / Document Picker Selection BottomSheet
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
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            'pdf',
                            'jpg',
                            'jpeg',
                            'png',
                            'doc',
                            'docx',
                            'ppt',
                            'pptx',
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

  // Add / Edit Dialog Box
  void _showAddOrEditDialog({CourseFileModel? existingFile}) {
    final titleController = TextEditingController(
      text: existingFile?.title ?? '',
    );
    final subjectController = TextEditingController(
      text: existingFile?.subject ?? '',
    );

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
                existingFile == null
                    ? "Add Course File / Note"
                    : "Edit File Details",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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

                    // File Selection Attachment (Only for New File)
                    if (existingFile == null) ...[
                      const Text(
                        "Attach Note / Document:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
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
                              const Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedFileName ??
                                      "Tap to capture photo or pick PDF/File...",
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
                            Text(
                              "Uploading file, please wait...",
                              style: TextStyle(fontSize: 12),
                            ),
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
                              const SnackBar(
                                content: Text("Please enter a file title"),
                              ),
                            );
                            return;
                          }

                          if (existingFile == null && selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please attach a file or capture photo first",
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isUploading = true);

                          try {
                            if (existingFile == null) {
                              // 1. Upload to Cloudinary
                              String downloadUrl =
                                  await AdminCourseFileService.uploadFileToStorage(
                                    selectedFile!,
                                    selectedFileName!,
                                  );

                              // 2. Save to Firestore
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
                              await AdminCourseFileService.addCourseFile(
                                newFile,
                              );
                            } else {
                              // Update Title & Subject
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
                  child: Text(
                    existingFile == null ? "Upload & Save" : "Save Changes",
                  ),
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
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Course Files & Notes",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor ?? Colors.blue,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 FILTERS SECTION
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                // Dept
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Dept",
                      labelStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                    ),
                    items: _departments
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(d, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDepartment = val!;
                        if (!_getAvailableSemesters().contains(
                          _selectedSemester,
                        )) {
                          _selectedSemester = '1st';
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),

                // Sem
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSemester,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Sem",
                      labelStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                    ),
                    items: _getAvailableSemesters()
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSemester = val!),
                  ),
                ),
                const SizedBox(width: 6),

                // Sec
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSection,
                    isExpanded: true,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Sec",
                      labelStyle: TextStyle(fontSize: 12),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                    ),
                    items: _sections
                        .map(
                          (sec) => DropdownMenuItem(
                            value: sec,
                            child: Text(sec, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSection = val!),
                  ),
                ),
              ],
            ),
          ),

          // 📄 COURSE FILES STREAM LIST
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

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE0F2FE),
                          child: Icon(
                            Icons.insert_drive_file_outlined,
                            color: Colors.teal,
                          ),
                        ),
                        title: Text(
                          file.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Subject: ${file.subject}\nBy: ${file.uploadedBy}",
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'view') {
                              // 🔥 Direct Browser / Viewer opening logic
                              _openFileUrl(file.fileUrl);
                            } else if (value == 'edit') {
                              _showAddOrEditDialog(existingFile: file);
                            } else if (value == 'share') {
                              if (file.fileUrl.isNotEmpty) {
                                SharePlus.instance.share(
                                  ShareParams(
                                    text:
                                        "Check out this course file: ${file.title}\nLink: ${file.fileUrl}",
                                  ),
                                );
                              }
                            } else if (value == 'delete') {
                              await AdminCourseFileService.deleteCourseFile(
                                file.id,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text("View"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.share,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text("Share"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text("Delete"),
                                ],
                              ),
                            ),
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
