// lib/features/student/blocs/schedule/widgets/student_schedule_entry_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';

/// Read-only card for a single [ScheduleModel] entry.
///
/// Named `StudentScheduleEntryCard` (not `ScheduleCard`) on purpose —
/// `features/student/widgets/schedule_card.dart` already defines a
/// `ScheduleCard` with a plain string-based constructor (subject/time/
/// teacher/room). That one is now legacy/unused now that schedules are
/// live-loaded, but keeping the names distinct avoids an import clash
/// wherever both might briefly coexist.
class StudentScheduleEntryCard extends StatelessWidget {
  final ScheduleModel schedule;

  const StudentScheduleEntryCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final start = DateFormat('hh:mm a').format(schedule.startTime);
    final end = DateFormat('hh:mm a').format(schedule.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  schedule.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                schedule.teacherName,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$start - $end',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
              Text(
                'Rm ${schedule.room}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
