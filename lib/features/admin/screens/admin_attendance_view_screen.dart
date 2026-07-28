import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:nexcampus_app/core/constants/app_theme.dart';
import '../models/attendance_model.dart';

class AdminAttendanceViewScreen extends StatefulWidget {
  const AdminAttendanceViewScreen({super.key});

  @override
  State<AdminAttendanceViewScreen> createState() => _AdminAttendanceViewScreenState();
}

class _AdminAttendanceViewScreenState extends State<AdminAttendanceViewScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Filters
  String? _selectedDepartment = 'Computer';
  String? _selectedSemester = '1st';
  String? _selectedSection = 'A';
  DateTime _selectedDate = DateTime.now();

  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];
  final List<String> _semesters8 = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
  final List<String> _semesters10 = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

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
        title: const Text("Student Attendance View", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔍 FILTERS SECTION (Overflow Fixed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Dept Dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartment,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: "Dept",
                          labelStyle: TextStyle(fontSize: 12),
                          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                        items: _departments
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDepartment = val;
                            if (_selectedSemester != null && !_getAvailableSemesters().contains(_selectedSemester)) {
                              _selectedSemester = '1st';
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Sem Dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSemester,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: "Sem",
                          labelStyle: TextStyle(fontSize: 12),
                          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                        items: currentSemesters
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSemester = val),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Sec Dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSection,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: "Sec",
                          labelStyle: TextStyle(fontSize: 12),
                          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                        items: _sections
                            .map((sec) => DropdownMenuItem(
                                  value: sec,
                                  child: Text(sec, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSection = val),
                      ),
                    ),
                  ],
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
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📊 ATTENDANCE STREAM LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('attendance')
                  .where('department', isEqualTo: _selectedDepartment)
                  .where('semester', isEqualTo: _selectedSemester)
                  .where('section', isEqualTo: _selectedSection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No attendance records found for this section."));
                }

                final docs = snapshot.data!.docs;
                final allRecords = docs.map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                // Filter for selected date
                final dateRecords = allRecords.where((r) {
                  return r.date.year == _selectedDate.year &&
                      r.date.month == _selectedDate.month &&
                      r.date.day == _selectedDate.day;
                }).toList();

                // Stats calculation for the selected date
                int presentCount = dateRecords.where((r) => r.status.toLowerCase() == 'present').length;
                int absentCount = dateRecords.where((r) => r.status.toLowerCase() == 'absent').length;
                int leaveCount = dateRecords.where((r) => r.status.toLowerCase() == 'leave').length;

                return Column(
                  children: [
                    // Summary Banner
                    Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 5)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBadge("Present", presentCount, Colors.green),
                          _buildStatBadge("Absent", absentCount, Colors.red),
                          _buildStatBadge("Leave", leaveCount, Colors.orange),
                        ],
                      ),
                    ),

                    // List of Students Status
                    Expanded(
                      child: dateRecords.isEmpty
                          ? const Center(child: Text("No attendance taken for this date."))
                          : ListView.builder(
                              itemCount: dateRecords.length,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemBuilder: (context, index) {
                                final record = dateRecords[index];
                                Color statusColor = Colors.green;
                                if (record.status.toLowerCase() == 'absent') statusColor = Colors.red;
                                if (record.status.toLowerCase() == 'leave') statusColor = Colors.orange;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withValues(alpha:0.1),
                                      child: Text(
                                        record.studentRoll.isNotEmpty ? record.studentRoll : '${index + 1}',
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(record.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("Roll No: ${record.studentRoll}"),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: statusColor),
                                      ),
                                      child: Text(
                                        record.status.toUpperCase(),
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}