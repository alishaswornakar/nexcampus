import 'package:flutter/material.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final int totalStudents;
  final int presentStudents;
  final int absentStudents;

  const AttendanceSummaryCard({
    super.key,
    required this.totalStudents,
    required this.presentStudents,
    required this.absentStudents,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalStudents == 0
        ? 0
        : ((presentStudents / totalStudents) * 100).round();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [

          const Row(
            children: [
              Icon(
                Icons.fact_check,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                "Today's Attendance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: _SummaryItem(
                  title: "Students",
                  value: totalStudents.toString(),
                  color: Colors.blue,
                  icon: Icons.people,
                ),
              ),

              Expanded(
                child: _SummaryItem(
                  title: "Present",
                  value: presentStudents.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),

            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: _SummaryItem(
                  title: "Absent",
                  value: absentStudents.toString(),
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
              ),

              Expanded(
                child: _SummaryItem(
                  title: "Attendance",
                  value: "$percentage%",
                  color: Colors.orange,
                  icon: Icons.bar_chart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}