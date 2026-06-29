import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String subject;
  final String time;
  final String teacher;
  final String room;

  const ScheduleCard({
    super.key,
    required this.subject,
    required this.time,
    required this.teacher,
    required this.room,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(time),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [Text(teacher), Text("Rm $room")],
          ),
        ],
      ),
    );
  }
}
