import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/data/semester_data1.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
import 'package:nexcampus_app/features/student/blocs/question_bank/screens/drive_webview_screen.dart';

class SyllabusSubjectScreen extends StatelessWidget {
  final int semester;

  const SyllabusSubjectScreen({super.key, required this.semester});

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
                final specificLink = subject['syllabusDrive'] ?? '';
                final hasSpecificLink = specificLink.isNotEmpty;
                final driveLink = hasSpecificLink
                    ? specificLink
                    : rootDriveFolder;

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
                          onPressed: () {
                            if (!hasSpecificLink) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Subject-specific syllabus coming soon — showing the general folder for now.',
                                  ),
                                ),
                              );
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DriveWebViewScreen(
                                  title: "$shortName Syllabus",
                                  url: driveLink,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 18,
                          ),
                          label: const Text("Syllabus"),
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
