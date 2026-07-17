import 'package:flutter/material.dart';

import '../models/assignment_submission_model.dart';

class SubmissionCard extends StatelessWidget {
  final AssignmentSubmissionModel submission;
  final VoidCallback onTap;

  const SubmissionCard({
    super.key,
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      submission.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Roll: ${submission.roll}",
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [

                        const Icon(
                          Icons.picture_as_pdf,
                          size: 18,
                          color: Colors.red,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            submission.pdfName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: submission.grade.isEmpty
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        submission.grade.isEmpty
                            ? "Not Graded"
                            : "Grade : ${submission.grade}",
                        style: TextStyle(
                          color: submission.grade.isEmpty
                              ? Colors.orange
                              : Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
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
        ),
      ),
    );
  }
}