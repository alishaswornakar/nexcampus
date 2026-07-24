import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;

  final String? phone;
  final String? department;
  final String? photoUrl;

  // Teacher specific details
  final String? employeeId;
  final String? designation;
  final String? qualification;
  final String? experience;
  final DateTime? joiningDate;

  TeacherProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,

    this.phone,
    this.department,
    this.photoUrl,

    this.employeeId,
    this.designation,
    this.qualification,
    this.experience,
    this.joiningDate,
  });


  factory TeacherProfileModel.fromMap(
    Map<String, dynamic> map,
    String uid,
  ) {

    return TeacherProfileModel(

      uid: uid,

      fullName:
          map['fullName'] ?? '',

      email:
          map['email'] ?? '',

      role:
          map['role'] ?? 'teacher',


      phone:
          map['phone'],

      department:
          map['department'],


      photoUrl:
          map['photoUrl'],


      employeeId:
          map['employeeId'],


      designation:
          map['designation'],


      qualification:
          map['qualification'],


      experience:
          map['experience'],


      joiningDate:
          map['joiningDate'] != null
              ? (map['joiningDate'] as Timestamp)
                  .toDate()
              : null,

    );
  }



  Map<String, dynamic> toMap() {

    return {

      "fullName": fullName,

      "email": email,

      "role": role,


      "phone": phone,

      "department": department,

      "photoUrl": photoUrl,


      "employeeId": employeeId,

      "designation": designation,

      "qualification": qualification,

      "experience": experience,


      "joiningDate":
          joiningDate != null
              ? Timestamp.fromDate(joiningDate!)
              : null,

    };
  }
}