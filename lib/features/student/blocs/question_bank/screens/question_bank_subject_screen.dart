import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/data/semester_subjects.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'drive_webview_screen.dart';

class QuestionBankSubjectScreen extends StatelessWidget {
  final int semester;

  const QuestionBankSubjectScreen({super.key, required this.semester});

  @override
  Widget build(BuildContext context) {
    final subjects = semesterSubjects[semester] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.secondary,
        title: Text(
          "Semester $semester",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: subjects.isEmpty
          ? const Center(
              child: Text(
                "No subjects available.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final fullName = subject['name'] ?? '';
                final shortName = subject['shortName'] ?? fullName;
                final qnbLink = subject['qnb'] ?? '';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: qnbLink.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DriveWebViewScreen(
                                        title: "$shortName Question Bank",
                                        url: qnbLink,
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(
                            Icons.description_outlined,
                            size: 18,
                          ),
                          label: const Text("QNB"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
