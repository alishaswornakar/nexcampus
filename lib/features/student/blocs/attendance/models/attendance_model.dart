import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final String id;
  final DateTime date;
  final String status;
  final String remarks;
  final DateTime checkIn;
  final DateTime checkOut;
  final DateTime createdAt;

  const AttendanceModel({
    required this.id,
    required this.date,
    required this.status,
    required this.remarks,
    required this.checkIn,
    required this.checkOut,
    required this.createdAt,
  });

  /// Convert Firestore document to AttendanceModel
  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return AttendanceModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      remarks: data['remarks'] ?? '',
      checkIn: (data['checkIn'] as Timestamp).toDate(),
      checkOut: (data['checkOut'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert AttendanceModel to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'status': status,
      'remarks': remarks,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with new values
  AttendanceModel copyWith({
    String? id,
    DateTime? date,
    String? status,
    String? remarks,
    DateTime? checkIn,
    DateTime? checkOut,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    status,
    remarks,
    checkIn,
    checkOut,
    createdAt,
  ];
}
