import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
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
  // Filters State
  String? _selectedDepartment = 'Computer Engineering';
  String? _selectedSemester = '1';

  /// Subject filter
  String? _selectedSubjectId;
  String _selectedSubjectName = 'All Subjects';

  /// Date filter
  DateTime _selectedDate = DateTime.now();

  /// Search & Status Filters
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All Students, 1: Present, 2: Absent

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSemesters = _getAvailableSemesters();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Attendance View',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Department Filter
            _buildLabel("Department"),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDepartment,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                        _selectedSemester = '1';
                      }
                      _selectedSubjectId = null;
                      _selectedSubjectName = 'All Subjects';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 🏷️ Semester & Date Filter Row
            Row(
              children: [
                // Semester Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Semester"),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSemester,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            items: currentSemesters
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      "Sem $s",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSemester = val;
                                _selectedSubjectId = null;
                                _selectedSubjectName = 'All Subjects';
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Date Picker Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Date"),
                      const SizedBox(height: 6),
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
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 🏷️ Subject Filter Stream Dropdown
            _buildLabel("Subject"),
            const SizedBox(height: 6),
            StreamBuilder<List<AdminSubjectModel>>(
              stream: AdminAttendanceService.getSubjects(
                department: _selectedDepartment ?? '',
                semester: _selectedSemester ?? '',
              ),
              builder: (context, subjectSnapshot) {
                final subjects = subjectSnapshot.data ?? [];

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

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSubjectId,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 📊 ATTENDANCE DATA STREAM & DISPLAY
            StreamBuilder<List<AttendanceModel>>(
              stream: AdminAttendanceService.getAttendanceByFilter(
                department: _selectedDepartment ?? '',
                semester: _selectedSemester ?? '',
                subjectId: _selectedSubjectId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allRecords = snapshot.data ?? [];

                // Filter for selected date
                final dateRecords = allRecords.where((r) {
                  return r.date.year == _selectedDate.year &&
                      r.date.month == _selectedDate.month &&
                      r.date.day == _selectedDate.day;
                }).toList();

                int presentCount = dateRecords.where((r) => r.isPresent).length;
                int absentCount = dateRecords.where((r) => !r.isPresent).length;
                int totalCount = dateRecords.length;

                // Filter logic for search & chip buttons
                final filteredRecords = dateRecords.where((r) {
                  final matchesSearch =
                      r.fullName.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      r.roll.toLowerCase().contains(_searchQuery.toLowerCase());

                  if (_selectedFilterIndex == 1) {
                    return matchesSearch && r.isPresent;
                  } else if (_selectedFilterIndex == 2) {
                    return matchesSearch && !r.isPresent;
                  }
                  return matchesSearch;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🟦 Class Overview Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Class Overview",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$_selectedSubjectName • Sem ${_selectedSemester ?? ''}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildOverviewStatCard(
                                "PRESENT",
                                "$presentCount",
                              ),
                              const SizedBox(width: 10),
                              _buildOverviewStatCard("Absent", "$absentCount"),
                              const SizedBox(width: 10),
                              _buildOverviewStatCard("Total", "$totalCount"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔍 Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: const InputDecoration(
                          hintText: "Search student name or roll no...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 🔘 Filter Chips (All Students / Present / Absent)
                    Row(
                      children: [
                        _buildFilterChip(0, "All Students"),
                        const SizedBox(width: 10),
                        _buildFilterChip(1, "Present"),
                        const SizedBox(width: 10),
                        _buildFilterChip(2, "Absent"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 👥 Students List Title
                    const Text(
                      "Students",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // List of Student Records
                    filteredRecords.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: Text(
                              dateRecords.isEmpty
                                  ? "No attendance taken for this date in $_selectedSubjectName."
                                  : "No matching student records found.",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: filteredRecords.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final record = filteredRecords[index];
                              final bool isPresent = record.isPresent;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage:
                                          record.photoUrl.isNotEmpty
                                          ? NetworkImage(record.photoUrl)
                                          : null,
                                      child: record.photoUrl.isEmpty
                                          ? Text(
                                              record.fullName.isNotEmpty
                                                  ? record.fullName[0]
                                                        .toUpperCase()
                                                  : 'S',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF3B52D4),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record.fullName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            record.roll.isNotEmpty
                                                ? record.roll
                                                : 'No Roll No',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPresent
                                            ? const Color(0xFFBBF7D0)
                                            : const Color(0xFFFECDD3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isPresent ? "PRESENT" : "ABSENT",
                                        style: TextStyle(
                                          color: isPresent
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF991B1B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🛠️ Helper UI Widgets

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildOverviewStatCard(String title, String count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
