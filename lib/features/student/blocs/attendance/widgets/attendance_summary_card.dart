import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final int totalClasses;
  final int present;
  final int absent;
  final int late;

  const AttendanceSummaryCard({
    super.key,
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.late,
  });

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (present / totalClasses) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Attendance Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildRow("Total Classes", totalClasses.toString()),

            const Divider(),

            _buildRow("Present", present.toString()),

            _buildRow("Absent", absent.toString()),

            _buildRow("Late", late.toString()),

            const Divider(),

            _buildRow(
              "Attendance",
              "${attendancePercentage.toStringAsFixed(2)} %",
              valueColor: attendancePercentage >= 75
                  ? Colors.green
                  : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
