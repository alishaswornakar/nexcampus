import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/attendance_model.dart';

class AttendanceDetailScreen extends StatefulWidget {
  final AttendanceModel attendance;

  const AttendanceDetailScreen({super.key, required this.attendance});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedFilter = "All Students";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double s(double value) => width * value / 390;

    final presentStudents = widget.attendance.students
        .where((e) => e.isPresent)
        .length;

    final absentStudents = widget.attendance.students.length - presentStudents;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        toolbarHeight: 56,
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Text(
          "Attendance Details",
          style: TextStyle(fontSize: s(22), fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.only(bottom: s(20)),
        children: [
          /// HEADER
          Padding(
            padding: EdgeInsets.fromLTRB(s(16), s(8), s(16), s(12)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(s(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.attendance.subjectName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: s(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: s(8)),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: s(12),
                      vertical: s(5),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${widget.attendance.department} • Semester ${widget.attendance.semester}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: s(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: s(10)),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: s(14),
                      ),

                      SizedBox(width: s(6)),

                      Text(
                        DateFormat(
                          "dd MMM yyyy",
                        ).format(widget.attendance.date),
                        style: TextStyle(color: Colors.white, fontSize: s(12)),
                      ),
                    ],
                  ),

                  SizedBox(height: s(12)),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          "Present",
                          presentStudents.toString(),
                          Colors.greenAccent,
                          s,
                        ),
                      ),

                      SizedBox(width: s(8)),

                      Expanded(
                        child: _summaryCard(
                          "Absent",
                          absentStudents.toString(),
                          Colors.redAccent,
                          s,
                        ),
                      ),

                      SizedBox(width: s(8)),

                      Expanded(
                        child: _summaryCard(
                          "Total",
                          widget.attendance.students.length.toString(),
                          Colors.white,
                          s,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s(16)),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search by student name or roll no...",
                prefixIcon: const Icon(Icons.search),

                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                contentPadding: EdgeInsets.symmetric(vertical: s(16)),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(s(16)),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(s(16)),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(s(16)),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: s(18)),

          /// Filter Chips
          SizedBox(
            height: s(42),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: s(16)),
              children: [
                _filterChip("All Students", s),

                SizedBox(width: s(10)),

                _filterChip("Present", s),

                SizedBox(width: s(10)),

                _filterChip("Absent", s),
              ],
            ),
          ),

          SizedBox(height: s(22)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: s(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Students Attendance",
                  style: TextStyle(
                    fontSize: s(20),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "${widget.attendance.students.length} Students",
                  style: TextStyle(
                    fontSize: s(13),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: s(16)),
          Builder(
            builder: (context) {
              var students = List.of(widget.attendance.students);

              /// Search
              if (_searchController.text.isNotEmpty) {
                final query = _searchController.text.toLowerCase();

                students = students.where((student) {
                  return student.fullName.toLowerCase().contains(query) ||
                      student.roll.toLowerCase().contains(query);
                }).toList();
              }

              /// Filter
              if (selectedFilter == "Present") {
                students = students.where((e) => e.isPresent).toList();
              } else if (selectedFilter == "Absent") {
                students = students.where((e) => !e.isPresent).toList();
              }

              if (students.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: s(40), bottom: s(30)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: s(80),
                        color: Colors.grey,
                      ),

                      SizedBox(height: s(14)),

                      Text(
                        "No students found",
                        style: TextStyle(
                          fontSize: s(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: s(16)),
                itemCount: students.length,
                separatorBuilder: (_, __) => SizedBox(height: s(12)),
                itemBuilder: (context, index) {
                  final student = students[index];

                  return Container(
                    padding: EdgeInsets.all(s(14)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(s(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: s(26),
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.12,
                          ),

                          backgroundImage: student.photoUrl.isNotEmpty
                              ? NetworkImage(student.photoUrl)
                              : null,

                          child: student.photoUrl.isEmpty
                              ? Text(
                                  student.fullName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: s(18),
                                  ),
                                )
                              : null,
                        ),

                        SizedBox(width: s(14)),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: s(17),
                                ),
                              ),

                              SizedBox(height: s(4)),

                              Text(
                                "Roll No: ${student.roll}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: s(13),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: s(14),
                            vertical: s(8),
                          ),
                          decoration: BoxDecoration(
                            color: student.isPresent
                                ? Colors.green.withValues(alpha:.15)
                                : Colors.red.withValues(alpha:.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            student.isPresent ? "Present" : "Absent",
                            style: TextStyle(
                              color: student.isPresent
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: s(13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    Color valueColor,
    double Function(double) s,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: s(10)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:.15),
        borderRadius: BorderRadius.circular(s(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: s(20),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: s(4)),

          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: s(10),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String title, double Function(double) s) {
    final bool selected = selectedFilter == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      borderRadius: BorderRadius.circular(s(12)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: s(18), vertical: s(10)),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xffECEFF5),
          borderRadius: BorderRadius.circular(s(12)),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: s(13),
          ),
        ),
      ),
    );
  }
}
