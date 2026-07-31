import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import '../models/attendance_model.dart';

class AttendanceHistoryTile extends StatelessWidget {
  final AttendanceModel attendance;
  final VoidCallback onTap;

  const AttendanceHistoryTile({
    super.key,
    required this.attendance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    double s(double value) => width * (value / 390);

    final totalStudents = attendance.students.length;

    final presentStudents =
        attendance.students.where((e) => e.isPresent).length;

    final absentStudents =
        totalStudents - presentStudents;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: s(16),
        vertical: s(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(s(22)),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xffEEF2FF),
              borderRadius:
                  BorderRadius.circular(s(22)),
            ),
            child: Padding(
              padding: EdgeInsets.all(s(18)),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// Top Row
                  Row(
                    children: [

                      Container(
                        padding: EdgeInsets.all(s(10)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  s(14)),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: AppTheme.primary,
                          size: s(22),
                        ),
                      ),

                      SizedBox(width: s(14)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            Text(
                              DateFormat(
                                      "dd MMM yyyy")
                                  .format(
                                      attendance.date),
                              style: TextStyle(
                                fontSize: s(18),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: s(4)),

                            Text(
                              "${attendance.department} • Semester ${attendance.semester}",
                              style: TextStyle(
                                fontSize: s(13),
                                color: Colors
                                    .grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: s(12),
                          vertical: s(6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green
                              .withValues(alpha:0.15),
                          borderRadius:
                              BorderRadius.circular(
                                  s(25)),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: s(15),
                            ),

                            SizedBox(width: s(5)),

                            Text(
                              "Completed",
                              style: TextStyle(
                                color:
                                    Colors.green,
                                fontSize: s(11),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),

                  SizedBox(height: s(18)),

                  /// Statistics Card
                  Container(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: s(18),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              s(18)),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: _statItem(
                            presentStudents
                                .toString(),
                            "PRESENT",
                           AppTheme.primary,
                            s,
                          ),
                        ),

                        Container(
                          width: 1,
                          height: s(45),
                          color: Colors
                              .grey.shade300,
                        ),

                        Expanded(
                          child: _statItem(
                            absentStudents
                                .toString(),
                            "ABSENT",
                            Colors.red,
                            s,
                          ),
                        ),

                        Container(
                          width: 1,
                          height: s(45),
                          color: Colors
                              .grey.shade300,
                        ),

                        Expanded(
                          child: _statItem(
                            totalStudents
                                .toString(),
                            "TOTAL",
                            Colors.black87,
                            s,
                          ),
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: s(14)),

                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        foregroundColor:
                           AppTheme.primary,
                      ),
                      iconAlignment:
                          IconAlignment.end,
                      icon: Icon(
                        Icons.arrow_forward,
                        size: s(18),
                      ),
                      label: Text(
                        "VIEW SESSION DETAILS",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: s(12),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(
    String value,
    String title,
    Color color,
    double Function(double) s,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Text(
          value,
          style: TextStyle(
            fontSize: s(24),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        SizedBox(height: s(4)),

        Text(
          title,
          style: TextStyle(
            fontSize: s(11),
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),

      ],
    );
  }
}