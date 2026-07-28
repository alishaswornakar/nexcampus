import 'package:flutter/material.dart';
import '../../classes/models/student_model.dart';

class AttendanceStudentTile extends StatelessWidget {
  final StudentModel student;
  final bool present;
  final ValueChanged<bool> onChanged;

  const AttendanceStudentTile({
    super.key,
    required this.student,
    required this.present,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              /// Student Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: student.photoUrl.isNotEmpty
                    ? NetworkImage(student.photoUrl)
                    : null,
                child: student.photoUrl.isEmpty
                    ? Text(
                        student.fullName.isNotEmpty
                            ? student.fullName[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 14),

              /// Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Roll: ${student.roll}",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            student.department,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// Status + Switch
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: present
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          present ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: present ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          present ? "Present" : "Absent",
                          style: TextStyle(
                            color: present ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Switch(
                    value: present,
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    onChanged: onChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
