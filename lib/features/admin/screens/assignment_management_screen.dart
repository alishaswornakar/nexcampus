import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../services/admin_assignment_service.dart';
import 'assignment_detail_screen.dart';
import 'submission_detail_screen.dart';

class AssignmentManagementScreen extends StatefulWidget {
  const AssignmentManagementScreen({super.key});

  @override
  State<AssignmentManagementScreen> createState() => _AssignmentManagementScreenState();
}

class _AssignmentManagementScreenState extends State<AssignmentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Filters
  String? _selectedDepartment;
  String? _selectedSemester;
  String? _selectedSection;

  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];
  
  // 8 Semesters List for Computer and Civil
  final List<String> _semesters8 = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'
  ];

  // 10 Semesters List for Architecture
  final List<String> _semesters10 = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'
  ];

  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  // 🎯 Helper method to get semester list based on selected department
  List<String> _getAvailableSemesters() {
    if (_selectedDepartment == 'Architecture') {
      return _semesters10;
    } else if (_selectedDepartment == 'Computer' || _selectedDepartment == 'Civil') {
      return _semesters8;
    }
    // If no department selected (All), allow all 10 semesters
    return _semesters10;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✏️ EDIT ASSIGNMENT DIALOG
  void _showEditAssignmentDialog(AssignmentModel assignment) {
    final titleController = TextEditingController(text: assignment.title);
    final descController = TextEditingController(text: assignment.description);
    DateTime selectedDeadline = assignment.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Assignment"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDeadline)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDeadline,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDeadline),
                              );
                              if (pickedTime != null) {
                                setDialogState(() {
                                  selectedDeadline = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: const Text("Change"),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await AdminAssignmentService.updateAssignment(assignment.id, {
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'deadline': Timestamp.fromDate(selectedDeadline),
                    });
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Assignment updated!")),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 👁️ VIEW DETAILS DIALOG
  void _showViewDetailsDialog(String title, String content, String metadata) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(metadata, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(),
              Text(content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor ?? Colors.blue;
    final currentSemesters = _getAvailableSemesters();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text("Assignment Management", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.assignment_outlined), text: "Teacher Posted"),
            Tab(icon: Icon(Icons.file_upload_outlined), text: "Student Submitted"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔍 FILTERS SECTION (Department, Semester, Section)
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                // Dept Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "Dept", contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All")),
                      ..._departments.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedDepartment = val;
                        // Department फेरिएपछि यदि पुरानो Semester नयाँ List मा छैन भने Reset गर्ने
                        final available = _getAvailableSemesters();
                        if (_selectedSemester != null && !available.contains(_selectedSemester)) {
                          _selectedSemester = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                
                // Dynamic Sem Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSemester,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "Sem", contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All")),
                      ...currentSemesters.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (val) => setState(() => _selectedSemester = val),
                  ),
                ),
                const SizedBox(width: 6),
                
                // Sec Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSection,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "Sec", contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("All")),
                      ..._sections.map((sec) => DropdownMenuItem(value: sec, child: Text(sec))),
                    ],
                    onChanged: (val) => setState(() => _selectedSection = val),
                  ),
                ),
              ],
            ),
          ),

          // 📜 TAB VIEWS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeacherAssignmentsTab(),
                _buildStudentSubmissionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1️⃣ TEACHER ASSIGNMENTS TAB
  Widget _buildTeacherAssignmentsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('assignments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No assignments found."));
        }

        final assignments = snapshot.data!.docs.map((doc) {
          return AssignmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).where((a) {
          if (_selectedDepartment != null && a.department != _selectedDepartment) return false;
          if (_selectedSemester != null && a.semester != _selectedSemester) return false;
          if (_selectedSection != null && a.section != _selectedSection) return false;
          return true;
        }).toList();

        return ListView.builder(
          itemCount: assignments.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final item = assignments[index];
            final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(item.createdDate);
            final deadlineStr = DateFormat('MMM dd, yyyy - hh:mm a').format(item.deadline);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignmentDetailScreen(assignment: item),
                    ),
                  );
                },
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("By: ${item.teacherName} | Dept: ${item.department} (${item.semester}-${item.section})"),
                    Text("Posted: $dateStr", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text("Deadline: $deadlineStr", style: const TextStyle(fontSize: 11, color: Colors.red)),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'view') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignmentDetailScreen(assignment: item),
                        ),
                      );
                    } else if (val == 'edit') {
                      _showEditAssignmentDialog(item);
                    } else if (val == 'share') {
                      AdminAssignmentService.shareAssignmentDetails(item.title, item.department, item.semester, deadlineStr);
                    } else if (val == 'delete') {
                      AdminAssignmentService.deleteAssignment(item.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, color: Colors.blue), SizedBox(width: 8), Text("View")])),
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.orange), SizedBox(width: 8), Text("Edit")])),
                    const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, color: Colors.green), SizedBox(width: 8), Text("Share")])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Delete")])),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2️⃣ STUDENT SUBMISSIONS TAB
  Widget _buildStudentSubmissionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('submissions').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No submissions found."));
        }

        final submissions = snapshot.data!.docs.map((doc) {
          return SubmissionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).where((s) {
          if (_selectedDepartment != null && s.department != _selectedDepartment) return false;
          if (_selectedSemester != null && s.semester != _selectedSemester) return false;
          if (_selectedSection != null && s.section != _selectedSection) return false;
          return true;
        }).toList();

        return ListView.builder(
          itemCount: submissions.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final item = submissions[index];
            final submitTimeStr = DateFormat('MMM dd, yyyy - hh:mm a').format(item.submittedAt);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubmissionDetailScreen(submission: item),
                    ),
                  );
                },
                title: Text("${item.studentName} (${item.studentRoll})", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Assignment: ${item.assignmentTitle}"),
                    Text("Dept: ${item.department} (${item.semester}-${item.section})"),
                    Text("Submitted At: $submitTimeStr", style: const TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'view') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmissionDetailScreen(submission: item),
                        ),
                      );
                    } else if (val == 'delete') {
                      AdminAssignmentService.deleteSubmission(item.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, color: Colors.blue), SizedBox(width: 8), Text("View Details")])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Delete")])),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}