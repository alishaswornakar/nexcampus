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
            "Computer Engineering",
          ),
          repository.totalStudents(
            "Civil Engineering",
          ),
          repository.totalStudents(
            "Architecture Engineering",
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
                title: "Computer Engineering",
                icon: Icons.computer,
                color: Colors.blue,
                totalStudents: counts[0],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SemesterScreen(
                        department:
                            "Computer Engineering",
                      ),
                    ),
                  );
                },
              ),

              DepartmentCard(
                title: "Civil Engineering",
                icon: Icons.architecture,
                color: Colors.orange,
                totalStudents: counts[1],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SemesterScreen(
                        department:
                            "Civil Engineering",
                      ),
                    ),
                  );
                },
              ),

              DepartmentCard(
                title:
                    "Architecture Engineering",
                icon: Icons.apartment,
                color: Colors.deepPurple,
                totalStudents: counts[2],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SemesterScreen(
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