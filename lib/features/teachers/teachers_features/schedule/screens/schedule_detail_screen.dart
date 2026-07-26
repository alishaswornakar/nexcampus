import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Schedule Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Subject",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      schedule.subject,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [

                    _tile(
                      Icons.school,
                      "Department",
                      schedule.department,
                    ),

                    const Divider(),

                    _tile(
                      Icons.layers,
                      "Semester",
                      schedule.semester,
                    ),

                    const Divider(),

                    _tile(
                      Icons.person,
                      "Teacher",
                      schedule.teacherName,
                    ),

                    const Divider(),

                    _tile(
                      Icons.calendar_today,
                      "Day",
                      schedule.day,
                    ),

                    const Divider(),

                    _tile(
                      Icons.access_time,
                      "Time",
                      "${TimeOfDay.fromDateTime(schedule.startTime).format(context)} - "
  "${TimeOfDay.fromDateTime(schedule.endTime).format(context)}",
                    ),

                    const Divider(),

                    _tile(
                      Icons.location_on,
                      "Room",
                      schedule.room,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orange,
                  foregroundColor:
                      Colors.white,
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Schedule",
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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor:
                      Colors.white,
                ),
                icon:
                    const Icon(Icons.delete),
                label:
                    const Text("Delete"),
                onPressed: () async {

                  final confirm =
                      await showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                AlertDialog(
                              title:
                                  const Text(
                                      "Delete Schedule"),
                              content:
                                  const Text(
                                      "Delete this schedule?"),
                              actions: [

                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(
                                          context,
                                          false),
                                  child:
                                      const Text(
                                          "Cancel"),
                                ),

                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(
                                          context,
                                          true),
                                  child:
                                      const Text(
                                          "Delete"),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                  if (!confirm) return;

                  await repository
                      .deleteSchedule(
                    schedule.id,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
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
    );
  }

  Widget _tile(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Icon(
          icon,
          color: Colors.blue,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        Text(value),
      ],
    );
  }
}