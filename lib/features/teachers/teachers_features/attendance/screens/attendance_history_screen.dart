import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/attendance/blocs/bloc/attendance_bloc.dart';

import '../repositories/attendance_repository.dart';
import '../services/attendance_service.dart';
import '../widgets/attendance_history_tile.dart';
import 'attendance_detail_screen.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final String department;
  final String semester;

  const AttendanceHistoryScreen({
    super.key,
    required this.department,
    required this.semester,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(
        AttendanceRepository(
          AttendanceService(),
        ),
      )..add(
          LoadAttendanceHistory(
            department: department,
            semester: semester,
          ),
        ),
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Attendance History",
          ),
        ),

        body: BlocBuilder<
            AttendanceBloc,
            AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (state is AttendanceError) {
              return Center(
                child: Text(
                  state.message,
                ),
              );
            }

            if (state
                is AttendanceHistoryLoaded) {
              if (state.attendance.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Attendance History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<
                          AttendanceBloc>()
                      .add(
                        LoadAttendanceHistory(
                          department:
                              department,
                          semester:
                              semester,
                        ),
                      );
                },

                child: ListView.builder(
                  padding:
                      const EdgeInsets.only(
                    top: 10,
                    bottom: 20,
                  ),
                  itemCount:
                      state.attendance.length,
                  itemBuilder:
                      (context, index) {
                    final attendance =
                        state.attendance[index];

                    return AttendanceHistoryTile(
                      attendance:
                          attendance,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AttendanceDetailScreen(
                              attendance:
                                  attendance,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}