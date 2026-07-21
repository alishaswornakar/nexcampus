import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a completed/cancelled queue record.
class QueueHistoryModel extends Equatable {
  /// Firestore document ID
  final String id;

  /// Student information
  final String studentId;
  final String studentName;
  final String rollNumber;

  /// Service information
  final String serviceId;
  final String serviceName;
  final String counterName;

  /// Token information
  final int tokenNumber;
  final String status;

  /// Queue date (yyyy-MM-dd)
  final String queueDate;

  /// Time when token was created
  final DateTime createdAt;

  /// Time when queue finished
  final DateTime? completedAt;

  const QueueHistoryModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.serviceId,
    required this.serviceName,
    required this.counterName,
    required this.tokenNumber,
    required this.status,
    required this.queueDate,
    required this.createdAt,
    this.completedAt,
  });

  factory QueueHistoryModel.empty() {
    return QueueHistoryModel(
      id: '',
      studentId: '',
      studentName: '',
      rollNumber: '',
      serviceId: '',
      serviceName: '',
      counterName: '',
      tokenNumber: 0,
      status: '',
      queueDate: '',
      createdAt: DateTime.now(),
      completedAt: null,
    );
  }

  QueueHistoryModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? rollNumber,
    String? serviceId,
    String? serviceName,
    String? counterName,
    int? tokenNumber,
    String? status,
    String? queueDate,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return QueueHistoryModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      counterName: counterName ?? this.counterName,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      status: status ?? this.status,
      queueDate: queueDate ?? this.queueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'counterName': counterName,
      'tokenNumber': tokenNumber,
      'status': status,
      'queueDate': queueDate,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  factory QueueHistoryModel.fromMap(Map<String, dynamic> map) {
    return QueueHistoryModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      counterName: map['counterName'] ?? '',
      tokenNumber: map['tokenNumber'] ?? 0,
      status: map['status'] ?? '',
      queueDate: map['queueDate'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory QueueHistoryModel.fromJson(String source) =>
      QueueHistoryModel.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    rollNumber,
    serviceId,
    serviceName,
    counterName,
    tokenNumber,
    status,
    queueDate,
    createdAt,
    completedAt,
  ];
}
