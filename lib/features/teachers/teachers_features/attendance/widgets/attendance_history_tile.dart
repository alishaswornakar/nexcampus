import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_model.dart';

class AttendanceHistoryTile extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback onTap;

  const AttendanceHistoryTile({
    super.key,
    required this.attendance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudents = attendance.students.length;

    final presentStudents = attendance.students
        .where((student) => student.isPresent)
        .length;

    final absentStudents =
        totalStudents - presentStudents;

    final percentage = totalStudents == 0
        ? 0
        : ((presentStudents / totalStudents) * 100)
            .round();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  const CircleAvatar(
                    backgroundColor:
                        Colors.blue,
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          DateFormat(
                            "dd MMM yyyy",
                          ).format(attendance.date),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${attendance.department} • Semester ${attendance.semester}",
                          style:
                              TextStyle(
                            color:
                                Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [

                  _buildStat(
                    "Total",
                    totalStudents.toString(),
                    Colors.blue,
                  ),

                  _buildStat(
                    "Present",
                    presentStudents.toString(),
                    Colors.green,
                  ),

                  _buildStat(
                    "Absent",
                    absentStudents.toString(),
                    Colors.red,
                  ),

                  _buildStat(
                    "%",
                    "$percentage%",
                    Colors.orange,
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [

        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

      ],
    );
  }
}