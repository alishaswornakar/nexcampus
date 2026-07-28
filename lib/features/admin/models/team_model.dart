class TeamModel {
  final String id;
  final String title;
  final String description;
  final String department;
  final String semester;
  final String projectType;
  final String status;
  final String leaderName;
  final int filledSlots;
  final int totalSlots;
  final String? rejectReason;

  TeamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.semester,
    required this.projectType,
    required this.status,
    required this.leaderName,
    required this.filledSlots,
    required this.totalSlots,
    this.rejectReason,
  });

  factory TeamModel.fromMap(Map<String, dynamic> map, String docId) {
    return TeamModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      projectType: map['projectType'] ?? '',
      status: map['status'] ?? 'Pending',
      leaderName: map['leaderName'] ?? '',
      filledSlots: map['filledSlots'] ?? 0,
      totalSlots: map['totalSlots'] ?? 0,
      rejectReason: map['rejectReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'department': department,
      'semester': semester,
      'projectType': projectType,
      'status': status,
      'leaderName': leaderName,
      'filledSlots': filledSlots,
      'totalSlots': totalSlots,
      if (rejectReason != null) 'rejectReason': rejectReason,
    };
  }
}
