import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/assignment_repository.dart';

import '../models/assignment_model.dart';

import '../services/assignment_service.dart';
import 'create_assignment_screen.dart';

class AssignmentDetailScreen extends StatelessWidget {
  final AssignmentModel assignment;

  AssignmentDetailScreen({
    super.key,
    required this.assignment,
  });

  final AssignmentRepository repository =
      AssignmentRepository(
    AssignmentService(),
  );

  @override
  Widget build(BuildContext context) {
    final bool isOverdue =
        assignment.dueDate.isBefore(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Assignment Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            /// Assignment Title
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Assignment",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// Description
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      assignment.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Column(
                  children: [

                    _infoTile(
                      Icons.school,
                      "Department",
                      assignment.department,
                    ),

                    const Divider(),

                    _infoTile(
                      Icons.layers,
                      "Semester",
                      assignment.semester,
                    ),

                    const Divider(),

                    _infoTile(
                      Icons.menu_book,
                      "Subject",
                      assignment.subject,
                    ),

                    const Divider(),

                    _infoTile(
                      Icons.calendar_month,
                      "Due Date",
                      DateFormat(
                        "dd MMM yyyy",
                      ).format(
                        assignment.dueDate,
                      ),
                    ),

                    const Divider(),

                    _infoTile(
                      isOverdue
                          ? Icons.warning
                          : Icons.check_circle,
                      "Status",
                      isOverdue
                          ? "Overdue"
                          : "Active",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orange,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Assignment",
                ),
                onPressed: () {
              Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) =>CreateAssignmentScreen(
    department: assignment.department,
    semester: int.parse(assignment.semester),
    selectedSubject: assignment.subject,
),
  ),
);
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                  foregroundColor:
                      Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                icon:
                    const Icon(Icons.delete),
                label:
                    const Text("Delete"),
                onPressed: () async {

                  final confirm =
                      await showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                AlertDialog(
                              title: const Text(
                                  "Delete Assignment"),
                              content:
                                  const Text(
                                "Are you sure you want to delete this assignment?",
                              ),
                              actions: [

                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context,
                                        false);
                                  },
                                  child: const Text(
                                      "Cancel"),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context,
                                        true);
                                  },
                                  child: const Text(
                                      "Delete"),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                  if (!confirm) return;

                  await repository
                      .deleteAssignment(
                    assignment.id,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        backgroundColor:
                            Colors.green,
                        content: Text(
                          "Assignment Deleted",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                    Icons.people),
                label: const Text(
                    "View Submissions"),
                onPressed: () {
                  // Next module
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Icon(
          icon,
          color: Colors.blue,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Text(value),
      ],
    );
  }
}