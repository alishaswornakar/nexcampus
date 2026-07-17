import 'package:flutter/material.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/repository/subject_repository.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/assignments/services/subject_services.dart';

import '../models/subject_model.dart';

import 'assignment_list_screen.dart';

class AssignmentSubjectScreen extends StatelessWidget {
  final String department;
  final int semester;

  AssignmentSubjectScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  final SubjectRepository repository =
      SubjectRepository(
    SubjectService(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          "Semester $semester",
        ),
      ),

      body: StreamBuilder<List<SubjectModel>>(
        stream: repository.getSubjects(
          department: department,
          semester: semester.toString(),
        ),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No subjects available",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          final subjects = snapshot.data!;

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {

              final subject =
                  subjects[index];

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Colors.orange
                            .shade100,
                    child: const Icon(
                      Icons.menu_book,
                      color:
                          Colors.orange,
                    ),
                  ),

                  title: Text(
                    subject.subject,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  trailing: const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AssignmentListScreen(
                          department:
                              department,
                          semester:
                              semester,
                          subject:
                              subject.subject,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}