import '../models/teacher_profile_model.dart';
import '../services/teacher_profile_service.dart';


class TeacherProfileRepository {

  final TeacherProfileService _service;


  TeacherProfileRepository(
    this._service,
  );



  /// Fetch teacher profile
  Future<TeacherProfileModel> getTeacherProfile() async {

    try {

      return await _service.getTeacherProfile();

    } catch (e) {

      throw Exception(
        e.toString(),
      );

    }

  }




  /// Watch teacher profile changes
  Stream<TeacherProfileModel> watchTeacherProfile() {

    try {

      return _service.watchTeacherProfile();

    } catch (e) {

      throw Exception(
        e.toString(),
      );

    }

  }




  /// Update teacher profile
  Future<void> updateTeacherProfile(
    Map<String, dynamic> data,
  ) async {

    try {

      await _service.updateTeacherProfile(
        data,
      );

    } catch (e) {

      throw Exception(
        e.toString(),
      );

    }

  }

}