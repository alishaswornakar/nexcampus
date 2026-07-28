import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String id; // Firestore Document ID
  final String teacherId; // Teacher Employee/College ID (e.g. TCH-001)
  final String name;
  final String email;
  final String phone;
  final String address; // Address Field
  final String department;
  final String qualification;

  TeacherModel({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.department,
    required this.qualification,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'department': department,
      'qualification': qualification,
      'role': 'teacher',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map, String docId) {
    return TeacherModel(
      id: docId,
      teacherId: map['teacherId'] ?? map['empId'] ?? '',
      name: map['name'] ?? map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      department: map['department'] ?? '',
      qualification: map['qualification'] ?? map['designation'] ?? '',
    );
  }
}