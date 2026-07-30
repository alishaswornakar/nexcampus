import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAttendanceHistoryScreen extends StatefulWidget {
  const AdminAttendanceHistoryScreen({super.key});

  @override
  State<AdminAttendanceHistoryScreen> createState() => _AdminAttendanceHistoryScreenState();
}

class _AdminAttendanceHistoryScreenState extends State<AdminAttendanceHistoryScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Filters
  String? _selectedDepartment = 'Computer';
  String? _selectedSemester = '1st';
  String? _selectedSubject;

  final List<String> _departments = ['Computer', 'Civil', 'Architecture'];
  final List<String> _semesters8 = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
  final List<String> _semesters10 = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];

  // Semester-wise Subjects list
  final Map<String, List<String>> _subjectMap = {
    '1st': ['Engineering Mathematics I', 'Physics', 'C Programming', 'Engineering Drawing'],
    '2nd': ['Engineering Mathematics II', 'Chemistry', 'Object Oriented Programming', 'Basic Electronics'],
    '3rd': ['Data Structures & Algorithms', 'Database Management System', 'Discrete Structure'],
    '4th': ['Microprocessor', 'Operating System', 'Numerical Methods', 'Computer Networks'],
    '5th': ['Software Engineering', 'Theory of Computation', 'Computer Architecture'],
    '6th': ['Compiler Design', 'Artificial Intelligence', 'Cryptography'],
    '7th': ['Distributed Systems', 'Cloud Computing', 'Project Management'],
    '8th': ['Big Data', 'Information Security', 'Final Project'],
  };

  List<String> _getAvailableSemesters() {
    if (_selectedDepartment == 'Architecture') {
      return _semesters10;
    }
    return _semesters8;
  }

  String _getFirestoreDeptName(String? uiDept) {
    if (uiDept == 'Computer') return 'Computer Engineering';
    if (uiDept == 'Civil') return 'Civil Engineering';
    if (uiDept == 'Architecture') return 'Architecture';
    return uiDept ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final currentSemesters = _getAvailableSemesters();
    final currentSubjects = _subjectMap[_selectedSemester] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: const Text("Attendance History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔍 FILTER SECTION
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Dept Dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: "Department",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: _departments
                            .map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDepartment = val;
                            _selectedSubject = null;
                            if (_selectedSemester != null && !_getAvailableSemesters().contains(_selectedSemester)) {
                              _selectedSemester = '1st';
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Semester Dropdown
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: "Semester",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: currentSemesters
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSemester = val;
                            _selectedSubject = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Subject Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  isExpanded: true,
                  hint: const Text("All Subjects", style: TextStyle(fontSize: 12)),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: "Subject",
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("All Subjects", style: TextStyle(color: Colors.grey)),
                    ),
                    ...currentSubjects.map((sub) => DropdownMenuItem(
                          value: sub,
                          child: Text(sub, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) => setState(() => _selectedSubject = val),
                ),
              ],
            ),
          ),

          // 📊 ATTENDANCE CARDS STREAM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db
                  .collection('attendance')
                  .where('department', isEqualTo: _getFirestoreDeptName(_selectedDepartment))
                  .where('semester', isEqualTo: _selectedSemester)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No attendance history found."));
                }

                // Filter docs by subject if selected
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (_selectedSubject != null && _selectedSubject!.isNotEmpty) {
                    String dbSub = (data['subject'] ?? '').toString().trim().toLowerCase();
                    String filterSub = _selectedSubject!.trim().toLowerCase();
                    return dbSub == filterSub;
                  }
                  return true;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No records found for the selected filter."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Format Date
                    String dateStr = "N/A";
                    if (data['date'] != null && data['date'] is Timestamp) {
                      DateTime dt = (data['date'] as Timestamp).toDate();
                      dateStr = DateFormat('dd MMM yyyy').format(dt);
                    }

                    // Extract Student Stats
                    List students = data['students'] is List ? data['students'] : [];
                    int total = students.length;
                    int present = students.where((s) => s['isPresent'] == true).length;
                    int absent = total - present;
                    int percentage = total > 0 ? ((present / total) * 100).round() : 0;

                    String dept = data['department'] ?? _selectedDepartment;
                    String sem = data['semester'] ?? _selectedSemester;
                    String subject = data['subject'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Card tap गर्दा detailed list मा पठाउने
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAttendanceDetailScreen(
                                dateStr: dateStr,
                                dept: dept,
                                sem: sem,
                                subject: subject,
                                students: List<Map<String, dynamic>>.from(students),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Date & Arrow Icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.calendar_month, color: Colors.blue, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 2),
                                        Text(
                                          "$dept • Semester $sem ${subject.isNotEmpty ? '• $subject' : ''}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),

                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 12),

                              // Stats Row: Total, Present, Absent, Percentage (%)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn("Total", "$total", Colors.blue),
                                  _buildStatColumn("Present", "$present", Colors.green),
                                  _buildStatColumn("Absent", "$absent", Colors.red),
                                  _buildStatColumn("%", "$percentage%", Colors.orange),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildStatColumn(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// 📄 DETAIL SCREEN: SHOWING STUDENT PRESENT/ABSENT LIST
class AdminAttendanceDetailScreen extends StatelessWidget {
  final String dateStr;
  final String dept;
  final String sem;
  final String subject;
  final List<Map<String, dynamic>> students;

  const AdminAttendanceDetailScreen({
    super.key,
    required this.dateStr,
    required this.dept,
    required this.sem,
    required this.subject,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      appBar: AppBar(
        title: Text(dateStr, style: const TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$dept - Semester $sem", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (subject.isNotEmpty)
                  Text("Subject: $subject", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final bool isPresent = student['isPresent'] ?? false;
                final String name = student['fullName'] ?? 'Unknown';
                final String roll = student['roll'] ?? '${index + 1}';
                final Color statusColor = isPresent ? Colors.green : Colors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Text(
                        roll,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Roll No: $roll"),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        isPresent ? "PRESENT" : "ABSENT",
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}