import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';


class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool isTeacher;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.isTeacher = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final start =
        DateFormat("hh:mm a").format(schedule.startTime);

    final end =
        DateFormat("hh:mm a").format(schedule.endTime);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// Subject
              Row(
                children: [
                  const Icon(
                    Icons.menu_book,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      schedule.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (isTeacher)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          onEdit?.call();
                        }

                        if (value == "delete") {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 10),
                              Text("Edit"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 18),

              _infoTile(
                Icons.calendar_today,
                schedule.day,
              ),

              const SizedBox(height: 10),

              _infoTile(
                Icons.access_time,
                "$start - $end",
              ),

              const SizedBox(height: 10),

              _infoTile(
                Icons.room,
                schedule.room,
              ),

              const SizedBox(height: 10),

              _infoTile(
                Icons.person,
                schedule.teacherName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [

        Icon(
          icon,
          color: Colors.grey.shade700,
          size: 20,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}