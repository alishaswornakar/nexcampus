import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexcampus_app/features/teachers/teachers_features/schedule/model/schedule_model.dart';


class ScheduleService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference get scheduleCollection =>
      firestore.collection("schedule");

  /// Create Schedule
  Future<void> createSchedule({
    required ScheduleModel schedule,
  }) async {
    try {
      await scheduleCollection
          .doc(schedule.id)
          .set(schedule.toMap());
    } catch (e) {
      throw Exception(
        "Failed to create schedule: $e",
      );
    }
  }

  /// Update Schedule
  Future<void> updateSchedule({
    required ScheduleModel schedule,
  }) async {
    try {
      await scheduleCollection
          .doc(schedule.id)
          .update(schedule.toMap());
    } catch (e) {
      throw Exception(
        "Failed to update schedule: $e",
      );
    }
  }

  /// Delete Schedule
  Future<void> deleteSchedule(
    String scheduleId,
  ) async {
    try {
      await scheduleCollection
          .doc(scheduleId)
          .delete();
    } catch (e) {
      throw Exception(
        "Failed to delete schedule: $e",
      );
    }
  }

  /// Teacher Schedule
  Stream<List<ScheduleModel>> getTeacherSchedule({
    required String teacherId,
  }) {
    return scheduleCollection
        .where(
          "teacherId",
          isEqualTo: teacherId,
        )
        .orderBy("day")
        .orderBy("startTime")
        .snapshots()
        .handleError((e) {
        print("Firestore Error: $e");
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

  /// Student Schedule
  Stream<List<ScheduleModel>> getStudentSchedule({
    required String department,
    required String semester,
  }) {
    return scheduleCollection
        .where(
          "department",
          isEqualTo: department,
        )
        .where(
          "semester",
          isEqualTo: semester,
        )
        .orderBy("day")
        .orderBy("startTime")
        .snapshots()
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

  /// Department + Semester Schedule
  Stream<List<ScheduleModel>> getSchedule({
    required String department,
    required String semester,
  }) {
    return scheduleCollection
        .where(
          "department",
          isEqualTo: department,
        )
        .where(
          "semester",
          isEqualTo: semester,
        )
        .orderBy("day")
        .orderBy("startTime")
        .snapshots()
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

  /// Single Schedule
  Future<ScheduleModel?> getScheduleById(
    String scheduleId,
  ) async {
    final doc = await scheduleCollection
        .doc(scheduleId)
        .get();

    if (!doc.exists) return null;

    return ScheduleModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }
}