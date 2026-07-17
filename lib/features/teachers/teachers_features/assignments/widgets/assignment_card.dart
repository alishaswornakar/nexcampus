import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/assignment_model.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverdue =
        assignment.dueDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      color: Colors.white,
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

              /// Title
              Row(
                children: [

                  const CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        Color(0xffE8F0FE),
                    child: Icon(
                      Icons.assignment,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Description
              Text(
                assignment.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [

                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    DateFormat(
                      "dd MMM yyyy",
                    ).format(
                      assignment.dueDate,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOverdue
                          ? "Overdue"
                          : "Active",
                      style: TextStyle(
                        color: isOverdue
                            ? Colors.red
                            : Colors.green,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
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