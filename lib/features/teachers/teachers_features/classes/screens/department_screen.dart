import 'package:flutter/material.dart';

import '../repository/classes_repository.dart';
import '../services/classes_service.dart';
import '../widgets/department_card.dart';
import 'semester_screen.dart';

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository =
        ClassesRepository(ClassesService());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Classes"),
        centerTitle: true,
      ),

      body: FutureBuilder<List<int>>(
        future: Future.wait([
          repository.totalStudents(
            "Computer",
          ),
          repository.totalStudents(
            "Civil",
          ),
          repository.totalStudents(
            "Architecture",
          ),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final counts = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              DepartmentCard(
                title: "Computer",
                icon: Icons.computer,
                color: Colors.blue,
                totalStudents: counts[0],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SemesterScreen(
                        department:
                            "Computer Engineering",
                      ),
                    ),
                  );
                },
              ),

              DepartmentCard(
                title: "Civil",
                icon: Icons.architecture,
                color: Colors.orange,
                totalStudents: counts[1],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SemesterScreen(
                        department:
                            "Civil",
                      ),
                    ),
                  );
                },
              ),

              DepartmentCard(
                title:
                    "Architecture",
                icon: Icons.apartment,
                color: Colors.deepPurple,
                totalStudents: counts[2],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SemesterScreen(
                        department:
                            "Architecture Engineering",
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}