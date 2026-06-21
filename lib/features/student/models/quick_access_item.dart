import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuickAccessItem {
  final IconData icon;
  final String title;

  QuickAccessItem({required this.icon, required this.title});
}


/// Student Model
class Student {
  final String? id;
  final String name;
  final String email;
  final String department;
  final int semester;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.semester,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert Student to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'semester': semester,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create Student from Firestore document
  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create Student from Map
  factory Student.fromMap(Map<String, dynamic> map, {String? id}) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() =>
      'Student(id: $id, name: $name, email: $email, department: $department, semester: $semester)';
}