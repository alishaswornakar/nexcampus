// lib/features/student/blocs/schedule/services/schedule_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nexcampus_app/features/student/blocs/schedule/model/schedule_model.dart';

/// Read-only counterpart of the teacher's ScheduleService
/// (features/teachers/teachers_features/schedule/services/schedule_service.dart).
///
/// Students never create/update/delete schedule entries, so those
/// methods are intentionally omitted here — this service only exposes
/// what the student side actually needs: the live class list for a
/// department + semester, and a single lookup for detail views.
class ScheduleService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get scheduleCollection =>
      firestore.collection("schedule");

  /// Live stream of every class posted for a department + semester,
  /// ordered by day then start time — same ordering the teacher side
  /// uses, so Sunday..Friday grouping on the student UI stays stable.
  Stream<List<ScheduleModel>> getStudentSchedule({
    required String department,
    required String semester,
  }) {
    return scheduleCollection
        .where("department", isEqualTo: department)
        .where("semester", isEqualTo: semester)
        .orderBy("day")
        .orderBy("startTime")
        .snapshots()
        .handleError((e) {
          debugPrint("Firestore Error (student schedule): $e");
        })
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ScheduleModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Single schedule entry — used by a detail/expanded view if needed.
  Future<ScheduleModel?> getScheduleById(String scheduleId) async {
    final doc = await scheduleCollection.doc(scheduleId).get();

    if (!doc.exists) return null;

    return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
