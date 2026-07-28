import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';

class AdminTeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  final CollectionReference _teamCollection =
      FirebaseFirestore.instance.collection('project_teams');

  // 1. Status (Pending, Approved, Rejected) अनुसार Real-time Teams को Stream ल्याउने
  Stream<List<TeamModel>> getTeamsByStatus(String status) {
    return _teamCollection
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TeamModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 2. सबै Project Teams हरूको Stream ल्याउने (Filter बिना)
  Stream<List<TeamModel>> getAllTeams() {
    return _teamCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TeamModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 3. Team Request को Status Update गर्ने (Approve वा Reject)
  Future<void> updateTeamStatus(String teamId, String status,
      {String? reason}) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
      };

      // यदि Status Reject गरिएको छ भने कारण (reason) थप्ने, नभए खाली गर्ने
      if (status == 'Rejected' && reason != null) {
        updateData['rejectReason'] = reason;
      } else if (status == 'Approved') {
        updateData['rejectReason'] = FieldValue.delete(); // Reject reason हटाउने
      }

      await _teamCollection.doc(teamId).update(updateData);
    } catch (e) {
      print("Error updating team status: $e");
      rethrow;
    }
  }

  // 4. Admin ले कुनै Post Delete गर्ने
  Future<void> deleteTeam(String teamId) async {
    try {
      await _teamCollection.doc(teamId).delete();
    } catch (e) {
      print("Error deleting team: $e");
      rethrow;
    }
  }
}