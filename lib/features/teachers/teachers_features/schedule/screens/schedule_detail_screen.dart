import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/screens/create_schedule_screen.dart';

import '../repository/schedule_repository.dart';
import '../services/schedule_service.dart';

class ScheduleDetailScreen extends StatelessWidget {
  final ScheduleModel schedule;

  ScheduleDetailScreen({
    super.key,
    required this.schedule,
  });

  final ScheduleRepository repository =
      ScheduleRepository(
    ScheduleService(),
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet =
        width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
            ? 24.0
            : 40.0;

    final maxWidth =
        width > 900 ? 750.0 : double.infinity;

    final titleSize = isMobile ? 24.0 : 28.0;
    final headingSize = isMobile ? 15.0 : 17.0;
    final bodySize = isMobile ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Schedule Details",
          style: TextStyle(
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              children: [

                /// SUBJECT CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Subject",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize:
                                headingSize,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          schedule.subject,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      isMobile ? 16 : 20,
                ),

                /// INFORMATION CARD
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        _tile(
                          Icons.school,
                          "Department",
                          schedule.department,
                          bodySize,
                        ),

                        const Divider(),

                        _tile(
                          Icons.layers,
                          "Semester",
                          schedule.semester,
                          bodySize,
                        ),

                        const Divider(),

                        _tile(
                          Icons.person,
                          "Teacher",
                          schedule.teacherName,
                          bodySize,
                        ),

                        const Divider(),

                        _tile(
                          Icons.calendar_today,
                          "Day",
                          schedule.day,
                          bodySize,
                        ),

                        const Divider(),

                        _tile(
                          Icons.access_time,
                          "Time",
                          "${TimeOfDay.fromDateTime(schedule.startTime).format(context)} - ${TimeOfDay.fromDateTime(schedule.endTime).format(context)}",
                          bodySize,
                        ),

                        const Divider(),

                        _tile(
                          Icons.location_on,
                          "Room",
                          schedule.room,
                          bodySize,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height:
                      isMobile ? 28 : 36,
                ),
                                /// EDIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 52 : 58,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: Text(
                      "Edit Schedule",
                      style: TextStyle(
                        fontSize:
                            isMobile ? 15 : 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      final updated =
                          await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddScheduleScreen(
                            department:
                                schedule.department,
                            semester:
                                schedule.semester,
                            schedule: schedule,
                          ),
                        ),
                      );

                      if (updated == true &&
                          context.mounted) {
                        Navigator.pop(
                          context,
                          true,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 14),

                /// DELETE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 52 : 58,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red,
                      foregroundColor:
                          Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.delete,
                    ),
                    label: Text(
                      "Delete Schedule",
                      style: TextStyle(
                        fontSize:
                            isMobile ? 15 : 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      final confirm =
                          await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    AlertDialog(
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            16),
                                  ),
                                  title: const Text(
                                    "Delete Schedule",
                                  ),
                                  content: const Text(
                                    "Delete this schedule?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          false,
                                        );
                                      },
                                      child: const Text(
                                        "Cancel",
                                      ),
                                    ),
                                    ElevatedButton(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red,
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          true,
                                        );
                                      },
                                      child: const Text(
                                        "Delete",
                                      ),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;

                      if (!confirm) {
                        return;
                      }

                      await repository
                          .deleteSchedule(
                        schedule.id,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(context);

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          backgroundColor:
                              Colors.green,
                          content: Text(
                            "Schedule Deleted",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String value,
    double fontSize,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: 22,
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 95,
            child: Text(
              title,
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              overflow:
                  TextOverflow.visible,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}