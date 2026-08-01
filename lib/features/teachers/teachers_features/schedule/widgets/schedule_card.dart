import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../model/schedule_model.dart';

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
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1000;

    final horizontalMargin = isMobile ? 12.0 : 20.0;
    final padding = isMobile ? 16.0 : 20.0;

    final titleSize = isMobile
        ? 17.0
        : isTablet
            ? 19.0
            : 21.0;

    final textSize = isMobile ? 14.0 : 16.0;

    final iconSize = isMobile ? 20.0 : 22.0;

    final start =
        DateFormat("hh:mm a").format(schedule.startTime);

    final end =
        DateFormat("hh:mm a").format(schedule.endTime);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
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
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              /// SUBJECT
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.menu_book,
                    color: AppTheme.primary,
                    size: iconSize,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      schedule.subject,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  if (isTeacher)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          onEdit?.call();
                        } else if (value ==
                            "delete") {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (_) => const [

                        PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
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
                              SizedBox(width: 8),
                              Text("Delete"),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              SizedBox(
                height: isMobile ? 16 : 20,
              ),

              _infoTile(
                Icons.calendar_today,
                schedule.day,
                iconSize,
                textSize,
              ),

              SizedBox(
                height: isMobile ? 10 : 12,
              ),

              _infoTile(
                Icons.access_time,
                "$start - $end",
                iconSize,
                textSize,
              ),

              SizedBox(
                height: isMobile ? 10 : 12,
              ),

              _infoTile(
                Icons.room,
                schedule.room,
                iconSize,
                textSize,
              ),

              SizedBox(
                height: isMobile ? 10 : 12,
              ),

              _infoTile(
                Icons.person,
                schedule.teacherName,
                iconSize,
                textSize,
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
    double iconSize,
    double textSize,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          color: AppTheme.primary,
          size: iconSize,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: textSize,
            ),
          ),
        ),
      ],
    );
  }
}