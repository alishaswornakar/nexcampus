import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a service counter available in the Digital Queue system.
///
/// Examples:
/// - Examination Section
/// - Accounts Section
/// - College Bank
/// - Library Clearance
/// - Certificate Section
class QueueServiceModel extends Equatable {
  /// Unique Firestore document ID.
  final String id;

  /// Display name of the service.
  final String name;

  /// Material icon name or custom icon identifier.
  ///
  /// Example:
  /// exam
  /// account_balance_wallet
  /// payments
  final String icon;

  /// Current token being served.
  final int currentToken;

  /// Number of students waiting.
  final int totalWaiting;

  /// Average service time per student (minutes).
  final int averageServiceTime;

  /// Whether this counter is currently open.
  final bool isOpen;

  /// Counter/desk number.
  ///
  /// Example:
  /// Counter 1
  /// Counter 2
  final String counterName;

  /// Display order on the screen.
  final int displayOrder;

  /// Last updated timestamp.
  final DateTime? updatedAt;

  const QueueServiceModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.currentToken,
    required this.totalWaiting,
    required this.averageServiceTime,
    required this.isOpen,
    required this.counterName,
    required this.displayOrder,
    this.updatedAt,
  });

  /// Empty object.
  factory QueueServiceModel.empty() {
    return const QueueServiceModel(
      id: '',
      name: '',
      icon: '',
      currentToken: 0,
      totalWaiting: 0,
      averageServiceTime: 5,
      isOpen: false,
      counterName: '',
      displayOrder: 0,
      updatedAt: null,
    );
  }

  QueueServiceModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? currentToken,
    int? totalWaiting,
    int? averageServiceTime,
    bool? isOpen,
    String? counterName,
    int? displayOrder,
    DateTime? updatedAt,
  }) {
    return QueueServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      currentToken: currentToken ?? this.currentToken,
      totalWaiting: totalWaiting ?? this.totalWaiting,
      averageServiceTime: averageServiceTime ?? this.averageServiceTime,
      isOpen: isOpen ?? this.isOpen,
      counterName: counterName ?? this.counterName,
      displayOrder: displayOrder ?? this.displayOrder,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Estimated waiting time in minutes.
  int get estimatedWaitingMinutes => totalWaiting * averageServiceTime;

  /// Whether students can join this queue.
  bool get canJoinQueue => isOpen;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'currentToken': currentToken,
      'totalWaiting': totalWaiting,
      'averageServiceTime': averageServiceTime,
      'isOpen': isOpen,
      'counterName': counterName,
      'displayOrder': displayOrder,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory QueueServiceModel.fromMap(Map<String, dynamic> map) {
    return QueueServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      currentToken: map['currentToken'] ?? 0,
      totalWaiting: map['totalWaiting'] ?? 0,
      averageServiceTime: map['averageServiceTime'] ?? 5,
      isOpen: map['isOpen'] ?? false,
      counterName: map['counterName'] ?? '',
      displayOrder: map['displayOrder'] ?? 0,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory QueueServiceModel.fromJson(String source) =>
      QueueServiceModel.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    currentToken,
    totalWaiting,
    averageServiceTime,
    isOpen,
    counterName,
    displayOrder,
    updatedAt,
  ];

  @override
  String toString() {
    return '''
QueueServiceModel(
  id: $id,
  name: $name,
  currentToken: $currentToken,
  waiting: $totalWaiting,
  averageServiceTime: $averageServiceTime,
  isOpen: $isOpen
)
''';
  }
}
