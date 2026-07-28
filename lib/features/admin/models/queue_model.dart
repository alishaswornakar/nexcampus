import 'package:cloud_firestore/cloud_firestore.dart';

class QueueModel {
  final String id;
  final int tokenNumber;
  final String studentName;
  final String studentId;
  final String serviceType; // Ex: Fee Payment, Document Verification
  final String status; // 'Waiting', 'Serving', 'Completed', 'Skipped'
  final String? counterName;
  final DateTime createdAt;

  QueueModel({
    required this.id,
    required this.tokenNumber,
    required this.studentName,
    required this.studentId,
    required this.serviceType,
    this.status = 'Waiting',
    this.counterName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tokenNumber': tokenNumber,
      'studentName': studentName,
      'studentId': studentId,
      'serviceType': serviceType,
      'status': status,
      'counterName': counterName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory QueueModel.fromMap(Map<String, dynamic> map, String docId) {
    return QueueModel(
      id: docId,
      tokenNumber: map['tokenNumber'] ?? 0,
      studentName: map['studentName'] ?? '',
      studentId: map['studentId'] ?? '',
      serviceType: map['serviceType'] ?? 'General',
      status: map['status'] ?? 'Waiting',
      counterName: map['counterName'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}