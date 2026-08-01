import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';
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
      )..add(
          const LoadTeacherProfileEvent(),
        ),
      child: const _TeacherProfileView(),
    );
  }
}

class _TeacherProfileView extends StatelessWidget {
  const _TeacherProfileView();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double horizontalPadding =
        isMobile ? 16 : (isTablet ? 20 : 28);

    final double avatarRadius =
        isMobile ? 55 : (isTablet ? 65 : 75);

    final double titleSize =
        isMobile ? 24 : (isTablet ? 26 : 28);

    final double emailSize =
        isMobile ? 14 : 16;

    final double buttonHeight =
        isMobile ? 54 : 60;

    final double buttonFont =
        isMobile ? 16 : 17;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Teacher Profile"),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),

      body: BlocBuilder<
          TeacherProfileBloc,
          TeacherProfileState>(
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
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          if (state is TeacherProfileLoaded) {

            final teacher = state.profile;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),

                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    horizontalPadding,
                  ),

                  child: Column(
                    children: [

                      /// Profile Avatar
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor:
                            Colors.blue.shade100,
                        backgroundImage:
                            teacher.photoUrl != null &&
                                    teacher.photoUrl!.isNotEmpty
                                ? NetworkImage(
                                    teacher.photoUrl!,
                                  )
                                : null,
                        child:
                            teacher.photoUrl == null ||
                                    teacher.photoUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: avatarRadius,
                                    color: AppTheme.primary,
                                  )
                                : null,
                      ),

                      SizedBox(
                        height:
                            isMobile ? 16 : 22,
                      ),

                      /// Teacher Name
                      Text(
                        teacher.fullName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Email
                      Text(
                        teacher.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: emailSize,
                          color:
                              Colors.grey.shade700,
                        ),
                      ),

                      SizedBox(
                        height:
                            isMobile ? 28 : 36,
                      ),

                      _buildInfoCard(
                        context: context,
                        icon: Icons.school,
                        title: "Department",
                        value: teacher.department ??
                            "Not Available",
                      ),

                      _buildInfoCard(
                        context: context,
                        icon: Icons.badge,
                        title: "Employee ID",
                        value: teacher.employeeId ??
                            "Not Available",
                      ),

                      _buildInfoCard(
                        context: context,
                        icon: Icons.work,
                        title: "Designation",
                        value: teacher.designation ??
                            "Not Available",
                      ),
                                            _buildInfoCard(
                        context: context,
                        icon: Icons.menu_book,
                        title: "Qualification",
                        value: teacher.qualification ??
                            "Not Available",
                      ),

                      _buildInfoCard(
                        context: context,
                        icon: Icons.star,
                        title: "Experience",
                        value: teacher.experience ??
                            "Not Available",
                      ),

                      _buildInfoCard(
                        context: context,
                        icon: Icons.phone,
                        title: "Phone",
                        value: teacher.phone ??
                            "Not Available",
                      ),

                      SizedBox(
                        height: isMobile ? 28 : 36,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: buttonFont,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BlocProvider.value(
                                  value: context.read<
                                      TeacherProfileBloc>(),
                                  child:
                                      EditTeacherProfileScreen(
                                    profile: teacher,
                                  ),
                                ),
                              ),
                            );

                            if (!context.mounted) {
                              return;
                            }

                            context
                                .read<TeacherProfileBloc>()
                                .add(
                                  const LoadTeacherProfileEvent(),
                                );
                          },
                        ),
                      ),

                      SizedBox(
                        height: isMobile ? 20 : 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
    Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final double avatarRadius =
        isMobile ? 22 : (isTablet ? 24 : 26);

    final double iconSize =
        isMobile ? 20 : 22;

    final double titleSize =
        isMobile ? 14 : 15;

    final double valueSize =
        isMobile ? 15 : 16;

    return Card(
      margin: EdgeInsets.only(
        bottom: isMobile ? 14 : 18,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 18,
          vertical: isMobile ? 12 : 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: iconSize,
              ),
            ),

            SizedBox(
              width: isMobile ? 12 : 16,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}