import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../models/attendance_model.dart';
import '../models/admin_subject_model.dart';
import '../services/admin_attendance_service.dart';

class AdminAttendanceViewScreen extends StatefulWidget {
  const AdminAttendanceViewScreen({super.key});

  @override
  State<AdminAttendanceViewScreen> createState() =>
      _AdminAttendanceViewScreenState();
}

class _AdminAttendanceViewScreenState extends State<AdminAttendanceViewScreen> {
  // Filters
  String? _selectedDepartment = 'Computer Engineering';
  String? _selectedSemester = '1';

  /// Subject filter
  String? _selectedSubjectId;
  String _selectedSubjectName = 'All Subjects';

  /// Date filter
  DateTime _selectedDate = DateTime.now();

  final List<String> _departments = [
    'Computer Engineering',
    'Civil Engineering',
    'Architecture',
  ];

  final List<String> _semesters8 = ['1', '2', '3', '4', '5', '6', '7', '8'];

  final List<String> _semesters10 = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  List<String> _getAvailableSemesters() {
    if (_selectedDepartment == 'Architecture') {
      return _semesters10;
    }
    return _semesters8;
  }

  @override
  Widget build(BuildContext context) {
    //final primaryColor = AppTheme.primaryColor ?? Colors.blue;
    final currentSemesters = _getAvailableSemesters();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text(
          "Student Attendance View",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔍 FILTERS SECTION
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Dept Dropdown
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
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
                            _selectedDepartment = val;
                            if (_selectedSemester != null &&
                                !_getAvailableSemesters().contains(
                                  _selectedSemester,
                                )) {
                              _selectedSemester = '1st';
                            }
                            // Subject list depends on department/semester,
                            // so any previously selected subject may no
                            // longer be valid — fall back to "All Subjects".
                            _selectedSubjectId = null;
                            _selectedSubjectName = 'All Subjects';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Sem Dropdown
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSemester,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Sem",
                          labelStyle: TextStyle(fontSize: 12),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                        ),
                        items: currentSemesters
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => setState(() {
                          _selectedSemester = val;
                          _selectedSubjectId = null;
                          _selectedSubjectName = 'All Subjects';
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subject Dropdown Row — scoped to the selected
                // department + semester, matching the teacher-side
                // subject-selection flow.
                StreamBuilder<List<AdminSubjectModel>>(
                  stream: AdminAttendanceService.getSubjects(
                    department: _selectedDepartment ?? '',
                    semester: _selectedSemester ?? '',
                  ),
                  builder: (context, subjectSnapshot) {
                    final subjects = subjectSnapshot.data ?? [];

                    // Keep the current selection if it's still valid for
                    // this department/semester; otherwise fall back.
                    final validIds = subjects.map((s) => s.id).toSet();
                    if (_selectedSubjectId != null &&
                        !validIds.contains(_selectedSubjectId)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _selectedSubjectId = null;
                            _selectedSubjectName = 'All Subjects';
                          });
                        }
                      });
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _selectedSubjectId,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "Subject",
                        labelStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            "All Subjects",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...subjects.map(
                          (s) => DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedSubjectId = val;
                          _selectedSubjectName = val == null
                              ? 'All Subjects'
                              : subjects
                                    .firstWhere(
                                      (s) => s.id == val,
                                      orElse: () => AdminSubjectModel(
                                        id: val,
                                        name: 'Unknown Subject',
                                      ),
                                    )
                                    .name;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Date Picker Row
                InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📊 ATTENDANCE STREAM LIST
          Expanded(
            child: StreamBuilder<List<AttendanceModel>>(
              // Real schema: one doc per class session, with a `students`
              // array. There is no `section` field to filter on.
              // Filtering now goes department -> semester -> subject, so
              // switching subjects here matches what the teacher already
              // sees for that department/semester/subject combination.
              stream: AdminAttendanceService.getAttendanceByFilter(
                department: _selectedDepartment ?? '',
                semester: _selectedSemester ?? '',
                subjectId: _selectedSubjectId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No attendance records found for this department/semester/$_selectedSubjectName.",
                    ),
                  );
                }

                // Already flattened to one record per student by
                // AdminAttendanceService.getAttendanceByFilter.
                final allRecords = snapshot.data!;

                // Filter for selected date
                final dateRecords = allRecords.where((r) {
                  return r.date.year == _selectedDate.year &&
                      r.date.month == _selectedDate.month &&
                      r.date.day == _selectedDate.day;
                }).toList();

                // Stats calculation for the selected date. Only
                // Present/Absent exist in the real data (isPresent is a
                // bool), so there is no separate Leave bucket.
                int presentCount = dateRecords.where((r) => r.isPresent).length;
                int absentCount = dateRecords.where((r) => !r.isPresent).length;

                return Column(
                  children: [
                    // Summary Banner
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBadge(
                            "Present",
                            presentCount,
                            Colors.green,
                          ),
                          _buildStatBadge("Absent", absentCount, Colors.red),
                        ],
                      ),
                    ),

                    // List of Students Status
                    Expanded(
                      child: dateRecords.isEmpty
                          ? Center(
                              child: Text(
                                "No attendance taken for this date${_selectedSubjectId != null ? ' in $_selectedSubjectName' : ''}.",
                              ),
                            )
                          : ListView.builder(
                              itemCount: dateRecords.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemBuilder: (context, index) {
                                final record = dateRecords[index];
                                final statusColor = record.isPresent
                                    ? Colors.green
                                    : Colors.red;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      backgroundImage:
                                          record.photoUrl.isNotEmpty
                                          ? NetworkImage(record.photoUrl)
                                          : null,
                                      child: record.photoUrl.isEmpty
                                          ? Text(
                                              record.roll.isNotEmpty
                                                  ? record.roll
                                                  : '${index + 1}',
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      record.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Subject name shown alongside roll no. so
                                    // it's clear which subject the student was
                                    // marked present/absent for — especially
                                    // useful when "All Subjects" is selected.
                                    subtitle: Text(
                                      "Roll No: ${record.roll}"
                                      "${record.subjectName.isNotEmpty ? ' • ${record.subjectName}' : ''}",
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        record.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
