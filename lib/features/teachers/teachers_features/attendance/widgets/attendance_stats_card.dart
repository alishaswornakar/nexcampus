import 'package:flutter/material.dart';

class AttendanceStatisticsCard extends StatelessWidget {
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;

  const AttendanceStatisticsCard({
    super.key,
    required this.totalStudents,
    required this.presentStudents,
    required this.absentStudents,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalStudents == 0
        ? 0
        : ((presentStudents / totalStudents) * 100);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Attendance Statistics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [

                _buildItem(
                  "Students",
                  totalStudents.toString(),
                  Colors.blue,
                  Icons.people,
                ),

                _buildItem(
                  "Present",
                  presentStudents.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),

                _buildItem(
                  "Absent",
                  absentStudents.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ],
            ),

            const SizedBox(height: 25),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor:
                    Colors.grey.shade300,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "${percentage.toStringAsFixed(1)}% Attendance",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [

        CircleAvatar(
          radius: 25,
          backgroundColor:
              color.withOpacity(0.15),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
