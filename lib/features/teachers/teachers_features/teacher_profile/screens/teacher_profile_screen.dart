import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_event.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/blocs/bloc/teacherprofile_state.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/teacher_profile/screens/edit_teacher_profile_screen.dart';

import '../repository/teacher_profile_repository.dart';
import '../services/teacher_profile_service.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeacherProfileBloc(
        TeacherProfileRepository(
          TeacherProfileService(),
        ),
      )..add(const LoadTeacherProfileEvent()),
      child: const _TeacherProfileView(),
    );
  }
}

class _TeacherProfileView extends StatelessWidget {
  const _TeacherProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Teacher Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: BlocBuilder<TeacherProfileBloc, TeacherProfileState>(
        builder: (context, state) {
          if (state is TeacherProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TeacherProfileError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is TeacherProfileLoaded) {
            final teacher = state.profile;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // Profile Picture
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: teacher.photoUrl != null &&
                            teacher.photoUrl!.isNotEmpty
                        ? NetworkImage(teacher.photoUrl!)
                        : null,
                    child: teacher.photoUrl == null ||
                            teacher.photoUrl!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue,
                          )
                        : null,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    teacher.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    teacher.email,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _buildInfoCard(
                    icon: Icons.school,
                    title: "Department",
                    value: teacher.department ?? "Not Available",
                  ),

                  _buildInfoCard(
                    icon: Icons.badge,
                    title: "Employee ID",
                    value: teacher.employeeId ?? "Not Available",
                  ),

                  _buildInfoCard(
                    icon: Icons.work,
                    title: "Designation",
                    value: teacher.designation ?? "Not Available",
                  ),

                  _buildInfoCard(
                    icon: Icons.menu_book,
                    title: "Qualification",
                    value: teacher.qualification ?? "Not Available",
                  ),

                  _buildInfoCard(
                    icon: Icons.star,
                    title: "Experience",
                    value: teacher.experience ?? "Not Available",
                  ),

                  _buildInfoCard(
                    icon: Icons.phone,
                    title: "Phone",
                    value: teacher.phone ?? "Not Available",
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                     onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<TeacherProfileBloc>(),
        child: EditTeacherProfileScreen(
          profile: teacher,
        ),
      ),
    ),
  );

  context.read<TeacherProfileBloc>().add(
    const LoadTeacherProfileEvent(),
  );
},
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}