import 'package:flutter/material.dart';

class AssignmentForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final String department;
  final int semester;
  final String subject;

  final DateTime? dueDate;

  final VoidCallback onSelectDate;

  const AssignmentForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.department,
    required this.semester,
    required this.subject,
    required this.dueDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Department Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.school,
                color: Colors.white,
              ),
            ),
            title: Text(
              department,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Semester $semester • $subject",
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "Assignment Title",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: "Enter assignment title",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "Description",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: descriptionController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: "Enter assignment description",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "Due Date",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: onSelectDate,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [

                const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    dueDate == null
                        ? "Select Due Date"
                        : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}