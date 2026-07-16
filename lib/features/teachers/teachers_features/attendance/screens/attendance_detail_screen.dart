import 'package:flutter/material.dart';

import '../models/attendance_model.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceDetailScreen({
    super.key,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final presentStudents = attendance.students
        .where((student) => student.isPresent)
        .length;

    final absentStudents =
        attendance.students.length - presentStudents;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Attendance Details",
        ),
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [

                _summaryCard(
                  "Total",
                  attendance.students.length.toString(),
                  Colors.white,
                ),

                _summaryCard(
                  "Present",
                  presentStudents.toString(),
                  Colors.greenAccent,
                ),

                _summaryCard(
                  "Absent",
                  absentStudents.toString(),
                  Colors.redAccent,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount:
                  attendance.students.length,
              itemBuilder: (context, index) {
                final student =
                    attendance.students[index];

                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Colors.blue.shade100,
                      backgroundImage:
                          student.photoUrl.isNotEmpty
                              ? NetworkImage(
                                  student.photoUrl,
                                )
                              : null,
                      child:
                          student.photoUrl.isEmpty
                              ? Text(
                                  student
                                      .fullName[0],
                                )
                              : null,
                    ),

                    title: Text(
                      student.fullName,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "Roll: ${student.roll}",
                    ),

                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: student.isPresent
                            ? Colors.green
                            : Colors.red,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        student.isPresent
                            ? "Present"
                            : "Absent",
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
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

  Widget _summaryCard(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [

        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}