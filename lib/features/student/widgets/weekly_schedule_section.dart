// lib/features/student/widgets/weekly_schedule_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

import 'package:nexcampus_app/features/student/blocs/user_profile/bloc/user_profile_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/bloc/user_profile_event.dart';
import 'package:nexcampus_app/features/student/blocs/user_profile/bloc/user_profile_state.dart';

import 'package:nexcampus_app/features/student/blocs/schedule/bloc/schedule_bloc.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/repository/schedule_repository.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/services/schedule_service.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/widgets/student_schedule_entry_card.dart';

/// Replaces the old hardcoded "Today's Schedule" block on the student
/// dashboard with a live, teacher-posted weekly timetable.
///
/// Shows Sunday -> Friday (no Saturday — matches the department's
/// weekly pattern), each labeled with that day's actual calendar date
/// for the current week, and lists whatever [ScheduleModel] entries
/// the teacher has posted for the student's department + semester on
/// that day.
///
/// Now backed by the student side's own ScheduleBloc/Repository/Service
/// (features/student/blocs/schedule/) instead of reaching into the
/// teacher feature directly — same "each screen wires its own
/// BlocProviders" convention used by GreetingCard.
class WeeklyScheduleSection extends StatelessWidget {
  final String studentId;

  const WeeklyScheduleSection({super.key, required this.studentId});

  static const List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              UserProfileBloc()
                ..add(UserProfileSubscriptionRequested(studentId)),
        ),
        BlocProvider(
          create: (_) => ScheduleBloc(ScheduleRepository(ScheduleService())),
        ),
      ],
      child: const _WeeklyScheduleBody(days: _days),
    );
  }
}

class _WeeklyScheduleBody extends StatelessWidget {
  final List<String> days;

  const _WeeklyScheduleBody({required this.days});

  /// Sunday of the current week (so "Sunday" always shows this week's
  /// date, not last week's, regardless of what day it is today).
  DateTime _startOfWeek() {
    final today = DateTime.now();
    final daysSinceSunday = today.weekday % 7; // Sunday(7)%7=0 ... Sat(6)%7=6
    return DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: daysSinceSunday));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileBloc, UserProfileState>(
      listenWhen: (previous, current) =>
          current.profile != null &&
          current.profile!.department != null &&
          current.profile!.semester != null &&
          (previous.profile?.department != current.profile?.department ||
              previous.profile?.semester != current.profile?.semester),
      listener: (context, state) {
        final profile = state.profile!;
        context.read<ScheduleBloc>().add(
          LoadStudentSchedulesEvent(
            department: profile.department!,
            semester: profile.semester!,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Weekly Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, profileState) {
              final profile = profileState.profile;

              if (profile == null ||
                  profile.department == null ||
                  profile.semester == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return BlocBuilder<ScheduleBloc, ScheduleState>(
                builder: (context, scheduleState) {
                  if (scheduleState is ScheduleLoading ||
                      scheduleState is ScheduleInitial) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (scheduleState is ScheduleError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Couldn't load schedule: ${scheduleState.message}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final schedules = scheduleState is SchedulesLoaded
                      ? scheduleState.schedules
                      : <ScheduleModel>[];

                  final sundayOfThisWeek = _startOfWeek();
                  final today = DateTime.now();

                  return Column(
                    children: List.generate(days.length, (i) {
                      final dayName = days[i];
                      final dayDate = sundayOfThisWeek.add(Duration(days: i));
                      final isToday = _isSameDate(dayDate, today);

                      final dayEntries =
                          schedules
                              .where(
                                (s) =>
                                    s.day.toLowerCase() ==
                                    dayName.toLowerCase(),
                              )
                              .toList()
                            ..sort(
                              (a, b) => a.startTime.compareTo(b.startTime),
                            );

                      return _DayScheduleGroup(
                        dayName: dayName,
                        dayDate: dayDate,
                        isToday: isToday,
                        entries: dayEntries,
                      );
                    }),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayScheduleGroup extends StatelessWidget {
  final String dayName;
  final DateTime dayDate;
  final bool isToday;
  final List<ScheduleModel> entries;

  const _DayScheduleGroup({
    required this.dayName,
    required this.dayDate,
    required this.isToday,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d').format(dayDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isToday ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: isToday ? AppTheme.primary : Colors.grey.shade600,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 4),
              child: Text(
                'No classes scheduled',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            )
          else
            ...entries.map(
              (schedule) => StudentScheduleEntryCard(schedule: schedule),
            ),
        ],
      ),
    );
  }
}
