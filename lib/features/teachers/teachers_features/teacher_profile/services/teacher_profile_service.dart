import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/teacher_profile_model.dart';


class TeacherProfileService {

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;


  TeacherProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;



  /// Get current logged in teacher profile
  Future<TeacherProfileModel> getTeacherProfile() async {

    final user = _auth.currentUser;


    if (user == null) {
      throw Exception(
        "User not logged in",
      );
    }


    final doc = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();



    if (!doc.exists) {

      throw Exception(
        "Teacher profile not found",
      );

    }


    return TeacherProfileModel.fromMap(
      doc.data()!,
      doc.id,
    );

  }





  /// Stream teacher profile
  Stream<TeacherProfileModel> watchTeacherProfile() {

    final user = _auth.currentUser;


    if (user == null) {

      throw Exception(
        "User not logged in",
      );

    }


    return _firestore
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .map(

          (doc) {

            if (!doc.exists) {

              throw Exception(
                "Profile does not exist",
              );

            }


            return TeacherProfileModel.fromMap(
              doc.data()!,
              doc.id,
            );

          },

        );

  }





  /// Update teacher profile
  Future<void> updateTeacherProfile(
    Map<String, dynamic> data,
  ) async {


    final user = _auth.currentUser;


    if (user == null) {

      throw Exception(
        "User not logged in",
      );

    }



    await _firestore
        .collection("users")
        .doc(user.uid)
        .update(
          data,
        );

  }

}