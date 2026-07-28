import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String rollNo;
  final String phone;
  final String address;
  final String department;
  final String semester;
  final String section;

  StudentModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.rollNo,
    required this.phone,
    required this.address,
    required this.department,
    required this.semester,
    required this.section,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'rollNo': rollNo,
      'phone': phone,
      'address': address,
      'department': department,
      'semester': semester,
      'section': section,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map, String docId) {
    return StudentModel(
      id: docId,
      uid: map['uid'] ?? docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      rollNo: map['rollNo'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
    );
  }
}