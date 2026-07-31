import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../blocs/bloc/attendance_bloc.dart';
import '../repositories/attendance_repository.dart';
import '../services/attendance_service.dart';
import '../widgets/attendance_history_tile.dart';
import '../widgets/attendance_search_bar.dart';
import 'attendance_detail_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final String department;
  final String semester;
  final String subjectId;

  const AttendanceHistoryScreen({
    super.key,
    required this.department,
    required this.semester,
    required this.subjectId,
  });

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends State<AttendanceHistoryScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String selectedFilter = "All";
  DateTimeRange? selectedDateRange;
  DateTime? customDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

 Widget _buildFilterChip(String title) {
  final bool selected = selectedFilter == title;

  return InkWell(
    onTap: () async {
      if (title == "Custom") {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
          initialDateRange: selectedDateRange,
        );

        if (picked != null) {
          setState(() {
            selectedFilter = title;
            selectedDateRange = picked;
          });
        }
      } else {
        setState(() {
          selectedFilter = title;
          selectedDateRange = null;
        });
      }
    },
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: selected
            ? Colors.transparent
            : const Color(0xffECEFF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected
              ? AppTheme.primary
              : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(
        AttendanceRepository(
          AttendanceService(),
        ),
      )..add(
          LoadAttendanceHistoryEvent(
            department: widget.department,
            semester: widget.semester,
            subjectId: widget.subjectId,
          ),
        ),
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),

        appBar: AppBar(
          backgroundColor:AppTheme.primary,
          elevation: 0,
          
          foregroundColor: Colors.white,
          centerTitle: false,
          title: const Text(
            "Attendance History",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        body: BlocBuilder<
            AttendanceBloc,
            AttendanceState>(
          builder: (context, state) {
            if (state is AttendanceLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AttendanceError) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is AttendanceHistoryLoaded) {
             var attendanceList = List.of(state.attendance);

              /// Search
              if (_searchController.text.isNotEmpty) {
                attendanceList = attendanceList.where((e) {
                  final query = _searchController.text
                      .toLowerCase();

                  return e.department
                          .toLowerCase()
                          .contains(query) ||
                      e.semester
                          .toLowerCase()
                          .contains(query);
                }).toList();
              }
              final now = DateTime.now();

switch (selectedFilter) {
  case "This Month":
    attendanceList = attendanceList.where((attendance) {
      return attendance.date.month == now.month &&
          attendance.date.year == now.year;
    }).toList();
    break;

  case "Last Month":
    int month = now.month - 1;
    int year = now.year;

    if (month == 0) {
      month = 12;
      year--;
    }

    attendanceList = attendanceList.where((attendance) {
      return attendance.date.month == month &&
          attendance.date.year == year;
    }).toList();
    break;

  case "Custom":
    if (selectedDateRange != null) {
      attendanceList = attendanceList.where((attendance) {
        final date = attendance.date;

        final start = DateTime(
          selectedDateRange!.start.year,
          selectedDateRange!.start.month,
          selectedDateRange!.start.day,
        );

        final end = DateTime(
          selectedDateRange!.end.year,
          selectedDateRange!.end.month,
          selectedDateRange!.end.day,
          23,
          59,
          59,
        );

        return !date.isBefore(start) &&
            !date.isAfter(end);
      }).toList();
    }
    break;

  case "All":
  default:
    break;
}

              if (attendanceList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
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
                      .read<AttendanceBloc>()
                      .add(
                        LoadAttendanceHistoryEvent(
                          department:
                              widget.department,
                          semester:
                              widget.semester,
                          subjectId:
                              widget.subjectId,
                        ),
                      );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        constraints.maxWidth;

                    double s(double value) =>
                        width * (value / 390);

                    return ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.only(
                        bottom: s(20),
                      ),
                      children: [

                        /// Search Bar
                        AttendanceSearchBar(
                          controller:
                              _searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          onClear: () {
                            _searchController
                                .clear();
                            setState(() {});
                          },
                        ),

                        /// Filter Chips
                        SizedBox(
                          height: s(42),
                          child: ListView(
                            scrollDirection:
                                Axis.horizontal,
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: s(16),
                            ),
                            children: [

                              _buildFilterChip(
                                  "All"),

                              SizedBox(
                                  width: s(10)),

                              _buildFilterChip(
                                  "This Month"),

                              SizedBox(
                                  width: s(10)),

                              _buildFilterChip(
                                  "Last Month"),

                              SizedBox(
                                  width: s(10)),

                              _buildFilterChip(
                                  "Custom"),
                            ],
                          ),
                        ),

                        SizedBox(height: s(25)),

                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: s(18),
                          ),
                          child: Text(
                            "Recent Sessions",
                            style: TextStyle(
                              fontSize: s(22),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: s(10)),

                        ...attendanceList.map(
                          (attendance) =>
                              AttendanceHistoryTile(
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
                          ),
                        ),
                      ],
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