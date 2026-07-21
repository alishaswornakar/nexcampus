import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Queue Status
class QueueStatus {
  static const String waiting = 'waiting';
  static const String serving = 'serving';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String missed = 'missed';

  static const List<String> values = [
    waiting,
    serving,
    completed,
    cancelled,
    missed,
  ];
}

/// Represents a student's queue token.
class QueueTokenModel extends Equatable {
  /// Firestore document id
  final String id;

  /// Student details
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String rollNumber;
  final String department;
  final String semester;
  final int priority;
  final String queueDate;
  final String deviceToken;

  /// Service details
  final String serviceId;
  final String serviceName;

  /// Queue number
  ///
  /// Example:
  /// 41
  final int tokenNumber;

  /// Student's current position.
  ///
  /// 1 means Next.
  final int queuePosition;

  /// Estimated waiting time (minutes)
  final int estimatedWaitMinutes;

  /// Queue status
  final String status;

  /// Counter assigned
  final String counterName;

  /// Token generation time
  final DateTime createdAt;

  /// When staff called this token
  final DateTime? calledAt;

  /// Completion time
  final DateTime? completedAt;

  /// Cancellation time
  final DateTime? cancelledAt;

  const QueueTokenModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.serviceId,
    required this.serviceName,
    required this.tokenNumber,
    required this.queuePosition,
    required this.estimatedWaitMinutes,
    required this.status,
    required this.counterName,
    required this.createdAt,
    required this.rollNumber,
    required this.department,
    required this.semester,
    required this.priority,
    required this.queueDate,
    required this.deviceToken,
    this.calledAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory QueueTokenModel.empty() {
    return QueueTokenModel(
      id: '',
      studentId: '',
      studentName: '',
      studentEmail: '',
      rollNumber: '',
      department: '',
      semester: '',
      priority: 0,
      queueDate: '',
      deviceToken: '',

      serviceId: '',
      serviceName: '',
      tokenNumber: 0,
      queuePosition: 0,
      estimatedWaitMinutes: 0,
      status: QueueStatus.waiting,
      counterName: '',
      createdAt: DateTime.now(),
      calledAt: null,
      completedAt: null,
      cancelledAt: null,
    );
  }

  QueueTokenModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? rollNumber,
    String? department,
    String? semester,
    int? priority,
    String? queueDate,
    String? deviceToken,
    String? serviceId,
    String? serviceName,
    int? tokenNumber,
    int? queuePosition,
    int? estimatedWaitMinutes,
    String? status,
    String? counterName,
    DateTime? createdAt,
    DateTime? calledAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return QueueTokenModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      priority: priority ?? this.priority,
      queueDate: queueDate ?? this.queueDate,
      deviceToken: deviceToken ?? this.deviceToken,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      queuePosition: queuePosition ?? this.queuePosition,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      status: status ?? this.status,
      counterName: counterName ?? this.counterName,
      createdAt: createdAt ?? this.createdAt,
      calledAt: calledAt ?? this.calledAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get isWaiting => status == QueueStatus.waiting;

  bool get isServing => status == QueueStatus.serving;

  bool get isCompleted => status == QueueStatus.completed;

  bool get isCancelled => status == QueueStatus.cancelled;

  bool get isMissed => status == QueueStatus.missed;

  bool get isActive => isWaiting || isServing;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'rollNumber': rollNumber,
      'department': department,
      'semester': semester,
      'priority': priority,
      'queueDate': queueDate,
      'deviceToken': deviceToken,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'tokenNumber': tokenNumber,
      'queuePosition': queuePosition,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'status': status,
      'counterName': counterName,
      'createdAt': Timestamp.fromDate(createdAt),
      'calledAt': calledAt != null ? Timestamp.fromDate(calledAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  factory QueueTokenModel.fromMap(Map<String, dynamic> map) {
    return QueueTokenModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      priority: map['priority'] ?? 0,
      queueDate: map['queueDate'] ?? '',
      deviceToken: map['deviceToken'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      tokenNumber: map['tokenNumber'] ?? 0,
      queuePosition: map['queuePosition'] ?? 0,
      estimatedWaitMinutes: map['estimatedWaitMinutes'] ?? 0,
      status: map['status'] ?? QueueStatus.waiting,
      counterName: map['counterName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      calledAt: map['calledAt'] != null
          ? (map['calledAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory QueueTokenModel.fromJson(String source) =>
      QueueTokenModel.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
    id,
    studentId,
    studentName,
    studentEmail,
    rollNumber,
    department,
    semester,
    priority,
    queueDate,
    deviceToken,
    serviceId,
    serviceName,
    tokenNumber,
    queuePosition,
    estimatedWaitMinutes,
    status,
    counterName,
    createdAt,
    calledAt,
    completedAt,
    cancelledAt,
  ];

  @override
  String toString() {
    return '''
QueueTokenModel(
  token: $tokenNumber,
  student: $studentName,
  service: $serviceName,
  status: $status,
  position: $queuePosition
)
''';
  }
}
