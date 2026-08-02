import 'package:flutter/material.dart';

import 'attendance_model.dart';

enum AttendanceStatus { onTrack, low, critical }

extension AttendanceStatusStyle on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.onTrack:
        return 'ON TRACK';
      case AttendanceStatus.low:
        return 'LOW';
      case AttendanceStatus.critical:
        return 'CRITICAL';
    }
  }

  Color get textColor {
    switch (this) {
      case AttendanceStatus.onTrack:
        return const Color(0xFF16A34A);
      case AttendanceStatus.low:
        return const Color(0xFFD97706);
      case AttendanceStatus.critical:
        return const Color(0xFFDC2626);
    }
  }

  Color get bgColor {
    switch (this) {
      case AttendanceStatus.onTrack:
        return const Color(0xFFDCFCE7);
      case AttendanceStatus.low:
        return const Color(0xFFFEF3C7);
      case AttendanceStatus.critical:
        return const Color(0xFFFEE2E2);
    }
  }
}

/// Aggregates a student's attendance records for a single subject.
class SubjectAttendanceSummary {
  final String subjectId;
  final String subjectName;
  final String teacherName;
  final List<AttendanceModel> records;

  const SubjectAttendanceSummary({
    required this.subjectId,
    required this.subjectName,
    required this.teacherName,
    required this.records,
  });

  int get totalClasses => records.length;
  int get present => records.where((r) => r.isPresent).length;
  int get absent => totalClasses - present;

  double get percentage =>
      totalClasses == 0 ? 0 : (present / totalClasses) * 100;

  AttendanceStatus get status {
    if (percentage >= 80) return AttendanceStatus.onTrack;
    if (percentage >= 65) return AttendanceStatus.low;
    return AttendanceStatus.critical;
  }

  /// Groups a flat list of session-level attendance rows into one summary
  /// per subject, keyed by subjectId (falls back to subjectName for older
  /// docs that don't carry an id).
  static List<SubjectAttendanceSummary> groupBySubject(
    List<AttendanceModel> records,
  ) {
    final Map<String, List<AttendanceModel>> grouped = {};

    for (final record in records) {
      final key = record.subjectId.isNotEmpty
          ? record.subjectId
          : (record.subjectName.isNotEmpty ? record.subjectName : 'unknown');
      grouped.putIfAbsent(key, () => []).add(record);
    }

    final summaries = grouped.entries.map((entry) {
      final first = entry.value.first;
      return SubjectAttendanceSummary(
        subjectId: first.subjectId,
        subjectName: first.subjectName.isNotEmpty
            ? first.subjectName
            : 'Unknown Subject',
        teacherName: first.teacherName,
        records: entry.value,
      );
    }).toList();

    summaries.sort((a, b) => a.subjectName.compareTo(b.subjectName));
    return summaries;
  }

  /// Weighted overall percentage across every subject — matches the
  /// "Overall Attendance" header card in the design.
  static double overallPercentage(List<AttendanceModel> records) {
    if (records.isEmpty) return 0;
    final present = records.where((r) => r.isPresent).length;
    return (present / records.length) * 100;
  }
}
